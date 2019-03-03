// test jsクラス
var AccountForms = function () {
    // prototypeで宣言した関数はselfで呼び出せます
    var self = this;

    // jQuery
    // $()で毎回命令を与えると都度オブジェクトを生成してしまうため変数に取っておく
    this.objectForJQuery = $("#idForJQuery");
    this.objectForJQuery.change(function () {
        self.disableV2webIfEwsIsActive();
    });

    this.deleteButton = $('#userdelete');
    this.deleteButton.click(function () {
        showVerifyPasswordModal(function () {
            $('#userdelete-from').submit();
        });
    });
};
// メソッドはコンストラクタの prototype プロパティに定義します
// （そこまで複雑な使い方をしないので {} で宣言しています、継承を考慮するなら一つずつprototype.xxx = function(){}で宣言します）
AccountForms.prototype = {
  testFunction: function () {
    console.log("newしてもらってConstracter.testFunctionで呼び出せます");
  },
  testFunction2: function () {
    console.log("newしてもらってConstracter.testFunction2で呼び出せます");
  }
};
