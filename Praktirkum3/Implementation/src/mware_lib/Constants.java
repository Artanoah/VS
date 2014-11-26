package mware_lib;

public class Constants {
	public static final String COMMAND_REBIND = "rebind";
	public static final String COMMAND_RESOLVE = "resolve";
	public static final String COMMAND_RESOLVEANSWER = "resolveAnswer";
	public static final String COMMAND_CALL = "call";
	public static final String COMMAND_CALLSUCCESSANSWER = "callAnswer";
	public static final String COMMAND_CALLERRORANSWER_INVALIDPARAM = "callAnswerInvalidParam";
	public static final String COMMAND_CALLERRORANSWER_OVERDRAFT = "callAnswerOverdraft";
	
	public static final String COMMAND_REBIND_OBJECTREFERENCE = "objectReference";
	public static final String COMMAND_RESOLVE_OBJECTNAME = "objectName";
	public static final String COMMAND_RESOLVEANSWER_OBJECTREFERENCE = "objectReference";
	public static final String COMMAND_CALL_OBJECTNAME = "objectName";
	public static final String COMMAND_CALL_METHODNAME = "methodName";
	public static final String COMMAND_CALL_ARGUMENTS = "arguments";
	public static final String COMMAND_CALLSUCCESSANSWER_OBJECTNAME = "callAnswer";
	public static final String COMMAND_CALLSUCCESSANSWER_ANSWER = "answer";
	public static final String COMMAND_CALLERRORANSWER_ANSWER = "error";
	
	public static final int PORT_NAMESERVICE = 50001;
	
	public static final String MATCHER_DOUBLE = "^-?[0-9]+(\\.[0-9]+)?$";
}
