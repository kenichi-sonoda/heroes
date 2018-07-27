/*
  時間は文字列で比較できる。
  例えば営業時間内かどうかの判断は以下とおり。
*/

function hoge(time, start, end) {
  if (start <= end) {
    return start <= time && time <= end;
  } else {
    return start <= time || time <= end;
  }
}

function assertEqual(actual, expected) {
  if (actual === expected) {
    console.log("OK");
  } else {
    console.log("NG:", "expected = [", expected, "] but got [", actual);
  }
}

assertEqual(hoge("12:00", "10:00", "13:00"), true);
assertEqual(hoge("09:00", "10:00", "13:00"), false);
assertEqual(hoge("14:00", "10:00", "13:00"), false);
assertEqual(hoge("23:00", "22:00", "09:00"), true);
assertEqual(hoge("08:00", "22:00", "09:00"), true);
assertEqual(hoge("21:00", "22:00", "09:00"), false);
assertEqual(hoge("10:00", "22:00", "09:00"), false);
