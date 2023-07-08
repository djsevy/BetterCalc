import 'dart:math';

const String EMPTY = "ERROR:_EMPTY_PARENTHESES"; //May be entirely unnecessary
const String SYNTAX_ERROR = "SYNTAX_ERROR";
const String DOMAIN_ERROR = "DOMAIN_ERROR";
const String DIVIDE_BY_ZERO = "ERROR:_DIVIDE_BY_ZERO";

class EquationCalc {
  //All member variables
  String currentEquation = "";
  String previousEquation = "";
  String previousAnswer = "";
  List<List<String>> history = [];
  String historyString = "";

  bool errorState = false;
  String errorType = "";


  /*
      Interaction logic
                        */
  setHistory(String imported) {
    // print(imported);
    try {
      
      // String imported = "1+1 2 4 4 ";
      List<String> importList = imported.trim().split(" ");

      List<String> equations = [];
      List<String> answers = [];
      for (int i = 0; i < importList.length; i++) {
        if (i.isEven) {
          equations.add(importList[i]);
        }
        if (i.isOdd) {
          answers.add(importList[i]);
        }
      }
      for (int i = 0; i < equations.length; i++)  {
        List<String> historyItem = [equations[i], answers[i]];
        history.add(historyItem);
      }

      historyString = imported;
    } catch (e) {
      // history = []; //do nothing, as this is already true
      //do nothing with historyString either
    }
  }

  setCurrentEquation(String equation) {
    currentEquation = equation;
  }

  solve() {
    //do the stack of things
    if (currentEquation != "") {
      // save current equation to previousEquation
      previousEquation = currentEquation;

      String converted = "";
      try {
        converted = convertEquation(currentEquation);
      } catch (e) {
        //Syntax Error
        converted = SYNTAX_ERROR; //not changing from the "" above is likely what was causing the error where nothign showed up on a string ending in '-'
        errorState = true;
        errorType = SYNTAX_ERROR;
      }

      String evaluated = evaluate(converted);
      //save evaluated answer to previousAnswer
      previousAnswer = evaluated;

      //Add them to history
      List<String> historyItem = [previousEquation, previousAnswer];
      history.insert(0, historyItem);
      historyString = previousEquation + " " + previousAnswer + " " + historyString; //This is important to remember

      //is this in-app scope needed at this point?
      //deleteSync?
      //Save hsitroy to Storage
      //historyToString method?

      // reset error state
      errorState = false;
      errorType = "";
    }
  }



  /*
      Translation logic
                        */
  String convertEquation(String equation) {
    //Stages:
    String equation2 = convertPlus(equation);
    String equation3 = convertMinus(equation2);

    String equation4 = convertTrigInverse(equation3);
    String equation5 = convertTrig(equation4);

    String equation6 = convertOperatorlessMult(equation5);
    String equation7 = convertNegative(equation6);
    String equation8 = convertSymbol(equation7);

    String equation9 = convertRoot(equation8);
    String equation10 = convertLog(equation9);

    return equation10;
  }

  String convertPlus(String equation) {
    String equation2 = equation.replaceAll("+", "#");
    String equation3 = equation2.replaceAll("e#", "e+");
    return equation3;
  }

  String convertMinus(String equation) {
    String equation2 = equation.replaceAll("—", "_");
    return equation2;
  }

  String convertNegative(String equation) {
    String equation2 = equation.replaceAll("-*", "-1*");
    return equation2;
  }

  String convertSymbol(String equation) {
    String equation2 = equation.replaceAll("ℼ", "${pi}").replaceAll("ℯ", "${e}").replaceAll("%", ".01");
    return equation2;
  }

  String convertOperatorlessMult(String equation) {
    //a number followed by anything that's not a number/float component/EMDAS operator/closing paren/bracket; or, a closing paren or num-symbol followed by a non-closing/non-operator
    String operatorlessMultPattern = "([0-9-][^0-9.e\\)\\]#_\\*/\\^\\+-])|([\\)ℼℯ][^#_\\*/\\^\\)\\]])";

    String equation2 = equation;
    // int multIndex = equation.indexOf(pattern)
    if (equation.contains(RegExp(operatorlessMultPattern))) {
      int multIndex = equation.indexOf(RegExp(operatorlessMultPattern));
      String left = equation[multIndex];
      equation2 = convertOperatorlessMult(equation2.replaceFirst(left, "${left}*", multIndex));
    }

    return equation2;
  }

  String convertTrigInverse(String equation) {
    // String trigInversePattern = "((sin)|(cos)|(tan))\\^-1";
    // print(equation.contains(RegExp(trigInversePattern)));
    String equation2 = equation.replaceAll("sin^-1", "trigars").replaceAll("cos^-1", "trigarc").replaceAll("tan^-1", "trigart");
    return equation2;
  }

  String convertTrig(String equation) {
    // String trigPattern = "(sin)|(cos)|(tan)";
    // print(equation.contains(RegExp(trigPattern)));
    String equation2 = equation.replaceAll("sin", "trigsin").replaceAll("cos", "trigcos").replaceAll("tan", "trigtan");
    return equation2;
  }


  String convertRoot(String equation) {
    String specialRootPattern = "\\[[^√]*\\]√"; //A left bracket, followed by no roots at least 0 times, followed by end bracket and root sign
    // print(RegExp(specialRootPattern));
    // print(equation.contains(RegExp(specialRootPattern)));

    String equation2 = equation;
    if (equation.contains(RegExp(specialRootPattern))) {
      int leftBracketIndex = equation.indexOf(RegExp(specialRootPattern));
      String left = equation[leftBracketIndex];
      equation2 = convertRoot(equation.replaceFirst(left, "(", leftBracketIndex).replaceFirst("]√", ")root", leftBracketIndex));
    }
    else if(equation.contains("√")) {
      equation2 = convertRoot(equation.replaceFirst("√", "2root"));
    }
    return equation2;
  }

  String convertLog(String equation) {
    String specialLogPattern = "log\\[[^\\]]*\\]"; //A left bracket, followed by no ']' for a log closing brace, followed by end bracket and root sign
    // print(RegExp(specialRootPattern));
    // print(equation.contains(RegExp(specialRootPattern)));
    // print(equation);

    String equation2 = equation;
    if (equation.contains(RegExp(specialLogPattern))) {
      int logIndex = equation.indexOf(RegExp(specialLogPattern));
      int leftBracketIndex = logIndex + 3; //TODO really technically should try/catch this, and throw an error in the class if wrong (this will break if the user deletes letters and stuff)
      int rightBracketIndex = equation.indexOf("]", logIndex);
      String logBase = equation.substring(leftBracketIndex+1, rightBracketIndex); //TODO End try/catch here
      equation2 = convertLog(equation.replaceFirst("log", "(${logBase})", logIndex).replaceFirst("[${logBase}]", "log", logIndex));
    }
    else if(equation.contains(RegExp("[^\\)]log"))) { //A log that hasn't been given a logbase param in parens yet but has things before it (an operator)
      int logIndex = equation.indexOf(RegExp("[^\\)]log")) + 1;
      equation2 = convertLog(equation.replaceFirst("log", "(10)log", logIndex));
    }
    else if (equation.contains(RegExp("^log"))) {
      equation2 = convertLog(equation.replaceFirst("log", "(10)log"));
    }
    else if(equation.contains("ln")) {
      equation2 = convertLog(equation.replaceFirst("ln", "(${e})log"));
    }
    // second else if

    return equation2;
  }
  //Em dash: — //currently used for subtraction
  //En dash: – //unused alternate option for subtraction
  //radical: √ (221A)
  //pi: ℼ (213C)
  //e: ℯ (212F)



  /*
      Evaluation logic
                        */
  String evaluate(String equation) {
    //in class version, this accesses data.
    bool has(String target) {
      return equation.contains(target);
    }

    //This will be formatted [subequation, answer]
    List<String> results = [];

    if (equation.isEmpty) {
      //return nothing/some special case or signal back to the phone to not commit the enter command. AND/OR make this check earlier.
      return EMPTY;
    }
    //This will escape recursion quickly instead of checking everything if an error happened earlier.
    if (errorState) {
      return errorType;
    }
    //otherwise, check if it's just one number. if it is, return it.
    if (validateOperand(equation)) {
      return equation;
    }

    //Check for parentheses left to resolve
    if (has("(") || has(")")) {
      results = doParentheses(equation);
    }

    //TODO trig check: all start with trig-, and it's sin, cos, tan, ars, arc, and art.
    else if(has("trig")) {
      results = getResult(equation, "trig");
    }

    else if(has("log")) {
      results = getResult(equation, "log");
    }

    else if(has("root")) {
      results = getResult(equation, "root");
    }

    //TODO root check

    else if (has("^")) {
      results = getResult(equation, "[\\^]"); //Necessary for regex
    }
    //Math begins here;
    else if (has("*") || has("/")) {
      results = getResult(equation, "[*/]");
    }
    else if (has("#") || has("_")) {
      results = getResult(equation, "[#_]");
    }
    //if no operands are found, meaning the string is just one 'number' but no valid number found, i.e. '-3-5'
    else if (validateOperand(equation) == false) {
      errorState = true;
      errorType = SYNTAX_ERROR;
      return errorType;
    }


    if (results[0].contains("ERROR")) { //TODO add "DOMAIN ERROR" and "DIVIDE BY 0 ERROR" as possible cases too
      return results[0];
    }
    return evaluate(equation.replaceFirst(results[0], results[1]));
  }

  List<String> getResult(equation, operatorSet) {
    List<String> params = findOperands(equation, operatorSet); //doesn't use params[0] cause that would replace it later. +|_? Need to be able to pick
    // print(params); // TODO remove
    String subequation = params[0];
    String answer = '';
    if (errorState) {
      answer = errorType; 
    }
    else {
      answer = doMath(params[1], params[2], params[3]);
    };
    // print("$subequation = $answer"); //TODO remove
    return [subequation, answer];
  }


  List<String> doParentheses(String equation) {
    String expression = ""; //expression will include parentheses
    String subequation = "";

    String expressionPattern = "\\([^\\(\\)]*\\)"; //parentheses are special in regex, a 'group', thus need escaped
    //if there's an end...
    if (equation.contains(")")) {
      //there must be a beginning
      if (equation.contains("(")) {
        //that means check what's inside
        int leftParenIndex = equation.indexOf(RegExp(expressionPattern));
        int RightParenIndex = equation.indexOf(")");
        //TODO may need try/catch here, playing with indices
        subequation = equation.substring(leftParenIndex + 1, RightParenIndex);
        expression = "(${subequation})";
      }
      //otherwise it's unfinished
      else {
        expression = SYNTAX_ERROR;
        errorState = true;
        errorType = SYNTAX_ERROR;
      }
    }
    //if there's no end but a beginning
    else {
      expression = SYNTAX_ERROR;
      errorState = true;
      errorType = SYNTAX_ERROR;
    }
    return [expression, evaluate(subequation)];
  }

  List<String> findOperands(String equation, String operatorPassed) {
    //TODO document a bit
    int operatorIndex = equation.indexOf(RegExp("${operatorPassed}")); //TODO: 'if operatorPasse.contains("trig"), special case, trig, 'sin', num are the things

    //There is an error if the operator is Trig where the character class of operatorPassed catches 'g' from 'log'. Will also catch 'o' from root/log/cos too.
    //TO solve, change character class (if needed) to be in the operator set passed?
    if (operatorPassed == "trig") { 
      String operator = equation.substring(operatorIndex+4, operatorIndex+7); //skip the 'trig' part of a trigsin.
      String afterOperandPattern = "([^0-9.e\\+-])";
      int afterOperandIndex = equation.indexOf(RegExp(afterOperandPattern), operatorIndex+7);

      // print(equation);
      // print(operatorPassed);
      // print(operatorIndex);
      // print("$afterOperandIndex"); //TODO remove

      String operand = '';
      try {
        operand = equation.substring(operatorIndex + 7, afterOperandIndex);
      } catch (e) {
        operand = equation.substring(operatorIndex + 7); //NOTE: modified to +1 here to fix '+8' being operand
        afterOperandIndex = equation.length;//TODO will this explode? Should not because this function won't get an empty string.
      }
      // print(operand); //TODO remove

      // print("trying to get subequation");
      String subequation = '';
      if (validateOperand(operand)) {
        try {
          subequation = equation.substring(operatorIndex, afterOperandIndex);
        } catch (e) {
          subequation = SYNTAX_ERROR;
          errorState = true;
          errorType = SYNTAX_ERROR;
        }
      }
      else {
        subequation = SYNTAX_ERROR;
        errorState = true;
        errorType = SYNTAX_ERROR;
      }

      // print(subequation);

      return [subequation, '', operator, operand];
    }

    String operator = equation[operatorIndex];
    if (operatorPassed == "log") {
      operator = "log";
    }
    if (operatorPassed == "root") {
      operator = "root";
    }

    String leftOperandPattern;
    if (operator == "*" || operator == "^") {
      leftOperandPattern = '([0-9.e\\+-]+\\' + '${operator})'; //version with escape in regex
    }
    else {
      leftOperandPattern = '([0-9.e\\+-]+' + '${operator})'; //version that doesn't need an escape
    }  
    //at least 1 number, followed by operator
    String afterRightOperandPattern = '([^0-9.e\\+-])'; //search for *non* valid stuff, starting after operatorIndex?
    int leftIndex = equation.indexOf(RegExp(leftOperandPattern));
    int afterRightEndIndex = equation.indexOf(RegExp(afterRightOperandPattern), operatorIndex+operator.length); //will err if input not perfect? Yes. 

    // print("trying left");
    String left = '';
    try {
      left = equation.substring(leftIndex, operatorIndex);
    } catch (e) {
      left = equation.substring(0, operatorIndex);
      leftIndex = 0;
    }

    // print("trying right");
    String right = '';
    try {
      right = equation.substring(operatorIndex + operator.length, afterRightEndIndex); //this will explode
    } catch (e) {
      right = equation.substring(operatorIndex + operator.length); //NOTE: modified to +1 here to fix '+8' being operand
      afterRightEndIndex = equation.length;//TODO will this explode? Should not because this function won't get an empty string.
    }

    // print("trying to get subequation");
    String subequation = '';
    if (validateOperand(left) && validateOperand(right)) {
      try {
        subequation = equation.substring(leftIndex, afterRightEndIndex);
      } catch (e) {
        subequation = SYNTAX_ERROR;
        errorState = true;
        errorType = SYNTAX_ERROR;
      }
    }
    else {
      subequation = SYNTAX_ERROR;
      errorState = true;
      errorType = SYNTAX_ERROR;
    }

    return [subequation, left, operator, right];
  }

  bool validateOperand(String operand) { //OR this will take left and right. OR or this will just check 1.
    // 'any amount of numbers (but at least 1), 'any amount (including 0).any amount (but at least 1)', 'case 2, but followed by exp notation
    String valid = '(^-?[0-9]+\$|^-?[0-9]*\\.[0-9]+\$|^-?[0-9]*\\.[0-9]+e[\\+-]?[0-9]+\$)'; 
    bool attempt = operand.contains(RegExp(valid)); 
    return attempt; 
  }

  String doMath(String left, String operator, String right) {
    double answer = 0;
    switch (operator) {
      case "#":
        answer = (double.parse(left) + double.parse(right)); //TODO convert this into a string again?
        break;

      case "_":
        answer = (double.parse(left) - double.parse(right));
        break;

      case "*":
        answer = (double.parse(left) * double.parse(right));
        break;

      case "/":
        answer = (double.parse(left) / double.parse(right));
        if (!answer.isFinite) {
          errorState = true;
          errorType = DIVIDE_BY_ZERO;
        }
        break;

      case "^":
        answer = pow(double.parse(left), double.parse(right)) as double;
        if (!answer.isFinite) {
          errorState = true;
          errorType = DOMAIN_ERROR;
        }
        break;
      case "root":
        answer = pow(double.parse(right), 1/double.parse(left)) as double;
        if (!answer.isFinite) {
          errorState = true;
          errorType = DOMAIN_ERROR;
        }
        break;

      case "sin":
        answer = sin(double.parse(right));
        break;
      case "cos":
        answer = cos(double.parse(right));
        break;
      case "tan":
        answer = tan(double.parse(right));
        if (answer > 100000000000000) {
          answer = double.infinity;
          errorState = true;
          errorType = DOMAIN_ERROR;
        }
        break;
      case "ars":
        answer = asin(double.parse(right));
        if (answer.isNaN) {
          errorState = true;
          errorType = DOMAIN_ERROR;
        }
        break;
      case "arc":
        answer = acos(double.parse(right));
        if (answer.isNaN) {
          errorState = true;
          errorType = DOMAIN_ERROR;
        }
        break;
      case "art":
        answer = atan(double.parse(right));
        break;

      case "log":
        answer = log(double.parse(right)) / log(double.parse(left));
        if (answer.isNaN) {
          errorState = true;
          errorType = DOMAIN_ERROR;
        }
        break;

      default:
        errorState = true;
        errorType = SYNTAX_ERROR;
    }
    return answer.toString();
    // return answer.toStringAsFixed(13); //This could have unintended consequences, but I think it'll work.
  }
}