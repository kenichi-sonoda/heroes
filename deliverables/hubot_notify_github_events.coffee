# github APIをポーリングして、必要に応じてアクションするスクリプト
# （変数名がsnakeケースなのはご容赦）
# またgithub webhookの仕様上、二人アサインすればアサインwebhookが２回飛ぶので、
# 一度のオペレーションですべて捌くのではなく1webhook単位で処理をしています

# variables
## CoffeeTips mapやfilterなどの引数を伴うメソッドは半角スペースを入れること

fs = require 'fs'
conf_data = JSON.parse(fs.readFileSync('./config.json'))
accounts = JSON.parse(fs.readFileSync('./data/accounts.json'))
hubot_webhook_key = conf_data.HUBOT_WEBHOOK_KEY
logger = require "../lib/logger"

my_slack_and_github_id = "kenichi-sonoda"
channel_name = "times-sonoda" ## ひとまず何かあったら嫌なので自分のチャンネルで
general_channel = "xxx"
repositories = ["repo1", "repo2", "repo3"]
hotfix_labels = [
  {
    "id": 496657460,
    "node_id": "MDU6TGFiZWw0OTY2NTc0NjA=",
    "name": "緊急度：HotFix"
  }
]
teiki_users_name_in_github = accounts.map (user) -> user.github_id

# main

module.exports = (robot) ->
  robot.router.post "/webhooks_sonoda", (request, response) ->
    # hubot_webhook_keyがクエリ文字列になければ一蹴
    unless request.query.key is hubot_webhook_key
      logger.app JSON.stringify(request.query)
      return response.end ""

    data = request.body ## リクエストボディ

    try
      ## issue
      if data.issue
        switch data.action
          ## openedの場合（通知しない）
          # when "opened"
          ## assignedの場合
          when "assigned"
            ## data直下のassigneeを確認
            if data.sender.login == data.assignee.login
              logger.app "本人によるアサインなのでスルー\n"
              return response.end ""
            ## 複数人アサインされたときはwebhookが複数回とんでしまうので、data.issueのassigneesは使えない
            searchedAccount = searchAccountByGithubID(data.assignee.login)
            if !searchedAccount?
              logger.app "登録されていないユーザーのため終了するぞ。\n"
              return response.end ""
            if searchedAccount.github_id == my_slack_and_github_id
              message = "@#{searchedAccount.slack_id} issueにアサインされたみたいだ、確認しとけよ？\n"
              message += "<#{data.issue.html_url}|#{data.issue.title}> @ #{data.repository.name}\n"
              channel_name = searchedAccount.slack_channel_name
            else if checkTeikiUser(searchedAccount.github_id) and checkRepository(data.repository.name)
              message = "@#{searchedAccount.slack_id} issueにアサインされたぞ。\n"
              message += "<#{data.issue.html_url}|#{data.issue.title}> @ #{data.repository.name}\n"
              channel_name = searchedAccount.slack_channel_name
            else
              logger.app "Applicant does not assigned.\n"
              return response.end ""
          # コメント投稿（PRの通常コメントもこちらで判断される）
          when "created"
            if checkTeikiUser(data.comment.user.login) and checkRepository(data.repository.name)
              issue_assignees = data.issue.assignees.map (assignee) ->
                searchedAccount = searchAccountByGithubID(assignee.login)
                if searchedAccount?
                  "@" + searchedAccount.slack_id
              issue_assignees = issue_assignees.filter (assignee) -> assignee # mapでsearchedAccountでひっかからなかったら空白の配列要素なので
              post_mentions = mentionsSearch(data.comment.body)
              if post_mentions
                message = "コメントが投稿されたぞ。 assignees: #{issue_assignees}\n"
                message += "<#{data.comment.html_url}|#{data.issue.title}> @ #{data.repository.name}\n"
                message += "#{post_mentions} 宛にメンションもついてるから確認してくれ。\n"
                channel_name = general_channel # メンションが複数あったときの対応がチャンネル１つ前提なので一旦ここになげる
              else
                logger.app "created（コメント）だけどメンションじゃなので投稿しないやつ。\n"
                return response.end ""
            else
              logger.app "created（コメント）だけど対象者じゃないので投稿しないやつ。\n"
              return response.end ""
          # ラベルが追加された（issue open時もイベント発火する）
          when "labeled"
            if checkHotfixLabel(data.label.id)
              message = "@channel hotfixのラベルが貼られたようだ。必要に応じて確認してくれ。\n"
              message += "<#{data.issue.html_url}|#{data.issue.title}> @ #{data.repository.name}\n"
              channel_name = general_channel
            else
              logger.app "hotfix外のlabeled\n"
              return response.end ""
          ## 他は無視
          else
            return response.end ""
      ## pull request
      else if data.pull_request
        logger.app "data.pull_request : true\n"
        switch data.action
          ## assignedの場合
          when "assigned"
            if data.sender.login == data.assignee.login
              logger.app "本人によるアサインなのでスルー"
              return response.end ""
            logger.app "assigned : true\n"
            ## data直下のassigneeを確認
            ## 複数人アサインされたときはwebhookが二回とぶので、data.pull_requestのassigneesは使えない
            searchedAccount = searchAccountByGithubID(data.assignee.login)
            if !searchedAccount?
              logger.app "登録されていないユーザーのため終了するぞ。"
              return response.end ""
            if searchedAccount.github_id == my_slack_and_github_id
              message = "@#{my_slack_and_github_id} PRにアサインされたぞ、腕がなるな！\n"
              message += "<#{data.pull_request.html_url}|#{data.pull_request.title}> @ #{data.repository.name}\n"
              channel_name = searchedAccount.slack_channel_name
            else if teiki_users_name_in_github.indexOf(searchedAccount.github_id) >= 0 and repositories.indexOf(data.repository.name) >= 0
              message = "@#{searchedAccount.slack_id} PRにアサインされたぞ。\n"
              message += "<#{data.pull_request.html_url}|#{data.pull_request.title}> @ #{data.repository.name}\n"
              channel_name = searchedAccount.slack_channel_name
            else
              logger.app "assigned : false\n"
              return response.end ""
          ## review_requestedの場合
          when "review_requested"
            logger.app "review_requested : true\n"
            ## data直下のrequested_reviewerを確認
            searchedAccount = searchAccountByGithubID(data.requested_reviewer.login)
            if !searchedAccount?
              logger.app "登録されていないユーザーのため終了するぞ。"
              return response.end ""
            if searchedAccount.github_id == my_slack_and_github_id
              message = "@#{my_slack_and_github_id} PRにレビュー依頼がきたぞ、迅速かつ丁寧にだな。\n"
              message += "<#{data.pull_request.html_url}|#{data.pull_request.title}> @ #{data.repository.name}\n"
              channel_name = searchedAccount.slack_channel_name
            else if teiki_users_name_in_github.indexOf(searchedAccount.github_id) >= 0 and repositories.indexOf(data.repository.name) >= 0
              message = "@#{searchedAccount.slack_id} PRにレビュー依頼がきたぞ。\n"
              message += "<#{data.pull_request.html_url}|#{data.pull_request.title}> @ #{data.repository.name}\n"
              channel_name = searchedAccount.slack_channel_name
            else
              logger.app "assigned : false\n"
              return response.end ""
          # レビュー投稿(add single commentとcode reviewはcreatedに)
          when "submitted"
            if checkTeikiUser(data.review.user.login) and checkRepository(data.repository.name)
              pr_assignees = data.pull_request.assignees.map (assignee) ->
                searchedAccount = searchAccountByGithubID(assignee.login)
                if searchedAccount?
                  "@" + searchedAccount.slack_id
              pr_assignees = pr_assignees.filter (assignee) -> assignee # mapでsearchedAccountでひっかからなかったら空白の配列要素なので
              post_mentions = mentionsSearch(data.review.body)
              if data.review.state == "approved"
                message = "PRがレビューでapprovedになったぞ。必要に応じてマージしてくれ。"
              else # commented, request_changed, そしてsingle comment（single commentは通知外にしたい）
                if !data.review.body # single commentにおけるsubmittedはbodyがnullのため
                  logger.app "single comment\n"
                  return response.end ""
                message = "PRにレビューしてもらったぞ。内容を確認してくれ。"
              # 以降はassignees情報とプルリクへのリンク、そしてメンション情報
              message += " assignees: #{pr_assignees}\n"
              message += "<#{data.review.html_url}|#{data.pull_request.title}> @ #{data.repository.name}\n"
              if post_mentions
                message += "#{post_mentions} 宛にメンションもついてるから確認してくれ。\n"
              channel_name = general_channel # 上書き
            else
              logger.app "レビューだけどteikiUser外、teikiリポジトリ外のため投稿しないやつ。\n"
              return response.end ""
          # コメント投稿（add single comment & code review）
          when "created"
            if checkTeikiUser(data.comment.user.login) and checkRepository(data.repository.name)
              pr_assignees = data.pull_request.assignees.map (assignee) ->
                searchedAccount = searchAccountByGithubID(assignee.login)
                if searchedAccount?
                  "@" + searchedAccount.slack_id
              pr_assignees = pr_assignees.filter (assignee) -> assignee # mapでsearchedAccountでひっかからなかったら空白の配列要素なので
              post_mentions = mentionsSearch(data.comment.body)
              if post_mentions # メンションが付いてるときだけポスト
                message = "PRにメンション付きコメントが投稿されたぞ。 assignees: #{pr_assignees}\n"
                message += "<#{data.comment.html_url}|#{data.pull_request.title}> @ #{data.repository.name}\n"
                message += "メンションの宛先は #{post_mentions} のようだ、確認してくれ。\n"
                channel_name = general_channel # 上書き
              else
                return response.end ""
            else
              return response.end ""
          ## assignedとreview_requested以外の場合は無視
          else
            return response.end ""

      ## それ以外
      else
        return response.end ""

      # messageはここで送信
      logger.app message
      robot.messageRoom channel_name, message
      return response.end ""

    catch error
      logger.error error

# Methods

## コメント本文のメンションを取得
mentionsSearch = (body) ->
  mentions = []
  regexp_str = body.match /(^|\s)(@[\w\-\/]+)/g
  if regexp_str
    for mention in regexp_str
      mentions.push(mention.trim())
    userNameSearchInTeikiTeam(mentions)
  else
    null

## teiki_teamにいるかユーザーをチェックして、slackのidに変換します
userNameSearchInTeikiTeam = (mentions) ->
  teikiUserNames = ""
  for mention in mentions
    # mentionには@が頭文字でついているので
    if teiki_users_name_in_github.indexOf(mention.slice(1)) >= 0
      searchedAccount = searchAccountByGithubID(mention.slice(1))
      if searchedAccount?
        teikiUserNames += "@" + searchedAccount.slack_id + " "
  if teikiUserNames
    teikiUserNames
  else
    logger.app "該当ユーザーがいないようだ\n"
    null

## github webhookにあるuser idがaccounts.jsonに含まれてるか通知する相手か検知する
checkTeikiUser = (user) ->
  if teiki_users_name_in_github.indexOf(user) >= 0
    return true
  else
    return false

checkRepository = (repository) ->
  if repositories.indexOf(repository) >= 0
    return true
  else
    return false

checkHotfixLabel = (label_id) ->
  for hotfix_label in hotfix_labels
    if hotfix_label.id == label_id
      return true
  return false

## 存在しない場合はundefinedがreturnされます
searchAccountByGithubID = (github_id) ->
  searchedAccount = accounts.filter (ac) -> ac.github_id == github_id
  return searchedAccount[0]
