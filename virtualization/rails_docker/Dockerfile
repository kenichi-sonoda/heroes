# 利用するイメージ
FROM centos:8

# Macでは標準で入っているRubyインストールに必要なパッケージをインストール
RUN yum update -y && \
    yum -y install bzip2 gcc openssl-devel readline-devel zlib-devel make

# Gitをインストールしてrbenvを導入
RUN yum -y install git
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
ENV PATH /root/.rbenv/shims:/root/.rbenv/bin:$PATH

# Install ruby-build & ruby
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    ~/.rbenv/bin/rbenv install 2.7.1 && \
    ~/.rbenv/bin/rbenv global 2.7.1

# Initiarize ruby encording
ENV RUBYOPT -EUTF-8

RUN gem install bundler -v "2.1.4"
# sasscでg++を、sqlite1.4.2でsqlite-develを、Webpackerでnodejs + yarnを求められるので
RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo
RUN yum -y install gcc-c++ sqlite-devel nodejs yarn
RUN gem install rails -v "6.0.3"

# PostgreSQL用のgem `pg` のビルドで必要になるライブラリを入れる
# https://qiita.com/tdrk/items/812e7ea763080e147757
RUN yum -y install postgresql-devel

RUN rbenv -v && \
    ruby -v && \
    bundler -v && \
    rails -v
