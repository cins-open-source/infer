DEFINE-CHECKER TEST_REFERENCE = {
  SET report_when =
          WHEN method_return_type("instancetype")
          AND HOLDS-NEXT WITH-TRANSITION Parameters
          (has_type("MyClass") OR has_type("MyClass &"))
          AND declaration_has_name(REGEXP("^new.*:$"))
          HOLDS-IN-NODE ObjCMethodDecl;
  SET message = "Found reference in parameter of method new";
};

DEFINE-CHECKER TEST_PARAMETER_LABEL = {
  LET method_has_parameter_type =
        WHEN
          HOLDS-NEXT WITH-TRANSITION ParameterName "number"
            (has_type("int"))
          HOLDS-IN-NODE ObjCMessageExpr;
  SET report_when =
      WHEN
         method_has_parameter_type
         AND call_method(REGEXP("^new.*:$"))
      HOLDS-IN-NODE ObjCMessageExpr;
  SET message = "Found method with parameter labeled with `number` and with type `int`";
};

DEFINE-CHECKER TEST_PARAMETER_LABEL_REGEXP = {
  LET method_has_parameter_type =
        WHEN
          HOLDS-NEXT WITH-TRANSITION ParameterName REGEXP("num.*")
            (has_type("int"))
          HOLDS-IN-NODE ObjCMessageExpr;
  SET report_when =
      WHEN
         method_has_parameter_type
         AND call_method(REGEXP("^new.*:$"))
      HOLDS-IN-NODE ObjCMessageExpr;
  SET message = "Found method with parameter labeled with `number` and with type `int`";
};

DEFINE-CHECKER TEST_PARAMETER_LABEL_EMPTY_STRUCT = {
  LET is_empty_init_list =
    WHEN ((is_node("ImplicitValueInitExpr")) HOLDS-EVERYWHERE-NEXT)
     HOLDS-IN-NODE InitListExpr;
  LET is_empty_struct =
    WHEN ((is_empty_init_list) HOLDS-EVERYWHERE-NEXT)
  	 HOLDS-IN-NODE CXXBindTemporaryExpr;
  LET method_has_parameter_type =
        WHEN
          HOLDS-NEXT WITH-TRANSITION ParameterName "newWithStruct"
            (is_empty_struct)
          HOLDS-IN-NODE ObjCMessageExpr;
  SET report_when =
      WHEN
         method_has_parameter_type
         AND call_method(REGEXP("^new.*:$"))
      HOLDS-IN-NODE ObjCMessageExpr;
  SET message = "Do not pass empty struct to the parameter `newWithStruct` of method `new...`";
};

DEFINE-CHECKER TEST_PARAMETER_LABEL_EMPTY_MAP = {
   //This means the node has no children.
  LET constructor_with_no_parameters =
    WHEN (FALSE HOLDS-EVERYWHERE-NEXT) HOLDS-IN-NODE CXXConstructExpr;

  LET temp_expr =
    WHEN (constructor_with_no_parameters HOLDS-EVERYWHERE-NEXT) HOLDS-IN-NODE CXXBindTemporaryExpr;

   LET is_empty_map =
    WHEN (temp_expr HOLDS-EVERYWHERE-NEXT) HOLDS-IN-NODE MaterializeTemporaryExpr;

  LET method_has_parameter_type =
        WHEN
          HOLDS-NEXT WITH-TRANSITION ParameterName "map"
            (is_empty_map)
          HOLDS-IN-NODE ObjCMessageExpr;
  SET report_when =
      WHEN
         method_has_parameter_type
         AND call_method(REGEXP("^new.*:$"))
      HOLDS-IN-NODE ObjCMessageExpr;
  SET message = "Do not pass empty map to the parameter `map` of method `new...`";
};

DEFINE-CHECKER TEST_PARAMETER_SELECTOR = {

 LET initialized_with_selector_expr =
  WHEN (is_node("ObjCSelectorExpr") HOLDS-EVERYWHERE-NEXT) HOLDS-IN-NODE CXXConstructExpr;

  LET materialized_with_selector_expr =
   WHEN (initialized_with_selector_expr HOLDS-EVENTUALLY) HOLDS-IN-NODE CXXConstructExpr;

  LET method_has_parameter_type =
        WHEN
          HOLDS-NEXT WITH-TRANSITION ParameterName "newWithAction"
            (initialized_with_selector_expr OR
            materialized_with_selector_expr)
          HOLDS-IN-NODE ObjCMessageExpr;

  SET report_when =
      WHEN
         method_has_parameter_type
         AND call_method(REGEXP("^new.*:$"))
      HOLDS-IN-NODE ObjCMessageExpr;
  SET message = "Do not construct the Component action with a selector only...`";
};

DEFINE-CHECKER DISCOURAGED_HASH_METHOD_INVOCATION = {
  SET report_when = call_method("hash");
  SET message = "Don't use the hash method";
};

DEFINE-CHECKER PARAMETER_TRANS_TYPE = {
  SET report_when =
    WHEN
      HOLDS-NEXT WITH-TRANSITION Parameters (has_type("int"))
      HOLDS-IN-NODE ObjCMessageExpr;
  SET message = "Found method called with an argument of type int";
};

DEFINE-CHECKER TEST_PARAMETER_SELECTOR_BY_TYPE = {

 LET initialized_with_selector_expr =
  WHEN (is_node("ObjCSelectorExpr") HOLDS-EVERYWHERE-NEXT) HOLDS-IN-NODE CXXConstructExpr;

  LET materialized_with_selector_expr =
   WHEN (initialized_with_selector_expr HOLDS-EVENTUALLY) HOLDS-IN-NODE CXXConstructExpr;

  LET method_has_parameter_type =
    WHEN
      HOLDS-NEXT WITH-TRANSITION Parameters
        (has_type("CKComponentAction") AND
        (initialized_with_selector_expr OR
        materialized_with_selector_expr))
      HOLDS-IN-NODE ObjCMessageExpr;

  SET report_when =
      WHEN
         method_has_parameter_type
         AND call_method(REGEXP("^new.*:$"))
      HOLDS-IN-NODE ObjCMessageExpr;
  SET message = "Do not construct the Component action with a selector only...`";
};

DEFINE-CHECKER NEW_COMPONENT_USING_MEM_MODEL = {
  SET report_when =
          WHEN method_return_type("instancetype")
          AND HOLDS-NEXT WITH-TRANSITION Parameters (has_type("REGEXP('FBMem.*')*"))
          AND declaration_has_name(REGEXP("^new.*:$"))
          HOLDS-IN-NODE ObjCMethodDecl;

  SET message = "Consider using fragment models instead.";
};
