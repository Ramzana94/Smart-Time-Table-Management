class AppValidators {
static String? validateEmail(String? value){
  if(value==null || value.trim().isEmpty){
    return "Email is required";
  }
  final emailRegex=RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'
  );
  if(!emailRegex.hasMatch(value.trim())){
    return "Enter a valid Email";
  }
return null;

}
// Password Validation
static String? validatePassword(String? value){
  if(value==null|| value.isEmpty){
    return "Password is required";
  }
  if(value.length<6){
return "Password must be atleast 6 characters";
  }
  return null;
}
// Confirm password
static String? validateConfirmPassword(
  String? value,String password){
    if(value==null || value.isEmpty){
      return "Confirm password is required";
    }
    if(value !=password){
      return "Password does not match";
    } return null;
  }
  // name Validation
  static String? validateName(String? value){
    if(value==null || value.trim().isEmpty){
      return "Name is required";
    }
    if(value.length<3){
      return "Name must be atleast 3 characters";
    }
    return null;
  }
  // phone validation
  static String? validatePhone(String? value){
    if(value==null || value.isEmpty){
      return "Phone Number is required";
    }
    if(value.length<10){
      return "Enter valid phone number";
    }
    return null;
  }
}