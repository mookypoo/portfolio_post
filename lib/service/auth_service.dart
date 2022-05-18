class AuthService {

  String? checkPhoneNumber({required String phoneNum, required void Function(String?) cb, String? code}){
    if (phoneNum.contains("-")) return "ⓘ -를 제외하고 입력해주세요.";
    if (phoneNum.length != 11) return "ⓘ 휴대전화번호 11자리를 입력해주세요.";
    if (phoneNum.contains(".")) return "ⓘ .를 제외하고 입력해주세요.";
    if (phoneNum.contains(",")) return "ⓘ ,를 제외하고 입력해주세요.";
    return null;
  }

  String? checkBirthday({required String bday}){
    if (bday.contains("-")) return "ⓘ -를 제외하고 입력해주세요.";
    if (bday.length != 6) return "ⓘ 생년월일 6자리를 입력해주세요.";
    return null;
  }

  String? checkName({required String name}){
    if (name.isEmpty) return "ⓘ 이름을 입력해주세요.";
    return null;
  }

  String? checkEmail({required String email}){
    if (email.isEmpty) return "ⓘ 이메일을 입력해주세요.";
    if (!email.contains("@")) return "ⓘ 옳바른 이메일 형식을 입력해주세요.";
    return null;
  }

  String? checkPw({required String pw}){
    // 65-90: capital letters
    // 48-57: numbers
    // special characters: 33 ~46, 58~64, 91~96, 123~128
    if (pw.length < 7) return "ⓘ 7자 이상의 비밀번호를 입력해주세요.";
    if (pw.length > 16) return "ⓘ 16자 이하의 비밀번호를 입력해주세요.";
    if (pw.contains("<") || pw.contains(">")) return "ⓘ <,>를 제외한 특수문자를 써주세요.";
    if (!pw.codeUnits.any((int i) => i >= 65 && i <= 90)
        && !pw.codeUnits.any((int i) => i >= 48 && i <= 57)
        && !pw.codeUnits.any((int i) => i >= 33 && i <= 46)
        && !pw.codeUnits.any((int i) => i >= 58 && i <= 64)
        && !pw.codeUnits.any((int i) => i >= 91 && i <= 96)
        && !pw.codeUnits.any((int i) => i >= 123 && i <= 128)
    ) return "ⓘ 영문 대문자, 숫자 특수문자 중 한개 이상 필요.";
    return null;
  }

  String? confirmPw({required String pw, required String pw2}){
    if (pw2.isEmpty) return "ⓘ 비밀번호를 다시 입력해주세요.";
    if (pw != pw2) return "ⓘ 비밀번호가 일치하지 않습니다.";
    return null;
  }
}