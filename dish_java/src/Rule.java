public class Rule {
	private String lvalue, rvalue;

	public Rule(String line) {
		String tmpline = line.substring(0, line.indexOf(';'));
		String[] tmpArr = tmpline.split("=");
		lvalue = tmpArr[0].trim();
		rvalue = Utility.convertToPostfix(tmpArr[1].trim()).trim();
	}

	public String getLval() {
		return lvalue;
	}

	public String getRval() {
		return rvalue;
	}
}
