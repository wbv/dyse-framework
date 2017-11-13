import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Stack;
import java.util.StringTokenizer;

public class Utility {

	public static void parseElements(List<Element> eleList, BufferedReader br,
			Map<String, Element> eleMap) {
		String line = "";
		try {
			while ((line = br.readLine()) != null) {
				if (line.contains("Rules:"))
					return;
				if (line.length() == 0) // read empty lines
					continue;
				Element tmpEle = new Element(line);
				eleList.add(tmpEle);
				if (eleMap.containsKey(tmpEle.getName())) {
					System.err
							.println("Repeating element: " + tmpEle.getName()); // repeating
																				// element
					System.exit(-1);
				}
				eleMap.put(tmpEle.getName(), tmpEle);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static void parseRules(List<ExecRules> erList, BufferedReader br,
			Map<Integer, List<ExecRules>> rankRuleLst, boolean isRank,
			int probVer, List<Double> accProb, List<ExecRules> orderRuleLst) {

		String line = "";
		double accumProb = 0.0;

		try {
			while ((line = br.readLine()) != null) {
				if (line.length() == 0) // read empty lines
					continue;
				line = line.trim();
				if (probVer == 1) { // only implement first version of prob
					int pos = line.indexOf(";");
					if (pos < 0)
						pos = line.indexOf("{");
					String tmp = line.substring(pos + 1).trim();
					if (tmp.length() == 0) {
						System.err.println("No probability exists in rules: "
								+ line);
						System.exit(-1);
					}
					if (Double.parseDouble(tmp) == 0) {
						System.err.println("Cannot have zero probability!!!");
						System.exit(-1);
					}
					accumProb += Double.parseDouble(tmp);
					if (accumProb - 1 > 0.01) {// the accumProb should be less
												// than or equal to 1
						System.out.println(accumProb);
						System.err
								.println("Accumulated probability exceeds 1!!!");
						System.exit(-1);
					}
					line = line.substring(0, pos + 1);
				}
				/*
				 * 1. 10: v1 = something v 2. 10: {} 3. 10*: {} 4. *{ (prob) }
				 * no rank, async v 5. { (prob) } no rank, sync v 6. v1 = v2 +
				 * v3; (prob)
				 */

				ExecRules er = new ExecRules(false);

				// case1: { } no rank, sync and case2: *{} no rank, async
				if (line.matches("\\**\\{")) {
					if (line.contains("*"))
						er.setAsync(true);
					while (!(line = br.readLine()).equals("}")) {
						if (line.length() == 0)
							continue; // empty line within group
						if (!line.matches(".*\\ =\\ .*;")) {
							System.err.println("Invalid rule: " + line);
							System.exit(-1);
						}
						er.addRule(new Rule(line));
					}
				}

				// case3: 10: v1 = something, normal rule with rank
				else if (line.matches("[0-9]*\\:.*")) {

					int rank = Integer.parseInt(line.substring(0,
							line.indexOf(':')).trim());
					String rule = line.substring(line.indexOf(':') + 1).trim();
					er.setAsync(true);
					er.addRule(new Rule(rule));
					List<ExecRules> tmpER = rankRuleLst.get(rank);
					if (tmpER == null)
						tmpER = new ArrayList<ExecRules>();
					tmpER.add(er);
					rankRuleLst.put(rank, tmpER);
				}

				// case4 and case5 10:{}/10*:{}
				else if (line.matches("[0-9]*\\**\\:\\{")) {
					int rank = 0;
					if (line.contains("*")) {
						er.setAsync(true);
						rank = Integer.parseInt(line.substring(0,
								line.indexOf('*')).trim());
					} else {
						rank = Integer.parseInt(line.substring(0,
								line.indexOf(':')).trim());
					}
					while (!(line = br.readLine()).equals("}")) {
						if (line.length() == 0)
							continue; // empty line within group
						if (!line.matches(".*\\ =\\ .*;")) {
							System.err.println("Invalid rule: " + line);
							System.exit(-1);
						}
						er.addRule(new Rule(line));
					}
					List<ExecRules> tmpER = rankRuleLst.get(rank);
					if (tmpER == null)
						tmpER = new ArrayList<ExecRules>();
					tmpER.add(er);
					rankRuleLst.put(rank, tmpER);
				}

				// case6 v1 = v2 + v3
				else if (line.matches(".*\\ =\\ .*")) {
					er.setAsync(true);
					er.addRule(new Rule(line));
				}

				// invalid rules!
				else {
					System.err.println("Invalid rule: " + line);
					System.exit(-1);
				}

				erList.add(er); // add the ExecRules to erList

				if (probVer == 1) {
					accProb.add(accumProb);
					orderRuleLst.add(er);
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		if (probVer == 1) {
			if (accumProb - 1 > 0.005) {
				System.err
						.println("The sum of probabilities is not equla to 1!");
				System.exit(-1);
			}
		}
	}

	private static boolean isOperator(char c) {
		return c == '+' || c == '*' || c == '!' || c == '(' || c == ')';
	}

	private static boolean isSpace(char c) {
		return (c == ' ');
	}

	private static boolean lowerPrecedence(char op1, char op2) {
		// Tell whether op1 has lower precedence than op2
		switch (op1) {
		case '+':
			return op2 == '*' || op2 == '!' || op2 == '(';
		case '*':
			return op2 == '(' || op2 == '!';
		case '!':
			return op2 == '(';
		case '(':
			return true;
		default: // (shouldn't happen)
			return false;
		}
	}

	public static String convertToPostfix(String infix) {
		// Return a postfix representation of the expression in infix.

		Stack<String> operatorStack = new Stack<String>(); // the stack of
		// operators
		char c; // the first character of a token
		StringTokenizer parser = new StringTokenizer(infix, "+*!() ", true);
		// StringTokenizer for the input string
		StringBuffer postfix = new StringBuffer(infix.length()); // result

		// Process the tokens.
		while (parser.hasMoreTokens()) {
			// get the next token and let c be the first character of this token
			String token = parser.nextToken();
			c = token.charAt(0);

			if ((token.length() == 1) && isOperator(c)) {
				// if token is an operator
				while (!operatorStack.empty()
						&& !lowerPrecedence(
								((String) operatorStack.peek()).charAt(0), c))
					// Operator on the stack does not have lower precedence, so
					// it goes before this one.
					postfix.append(" ").append((String) operatorStack.pop());
				if (c == ')') {
					// Output the remaining operators in the parenthesized part.
					if (operatorStack.empty()) {
						System.err.println("Parentheses mismatched");
						return null;
					}
					String operator = (String) operatorStack.pop();
					while (operator.charAt(0) != '(') {
						postfix.append(" ").append(operator);
						if (operatorStack.empty()) {
							System.err.println("Parentheses mismatched");
							return null;
						}
						operator = (String) operatorStack.pop();
					}
				} else {
					// Push this operator onto the stack.
					operatorStack.push(token);
				}
			} else if ((token.length() == 1) && isSpace(c)) {
				// else if token was a space ignore it
			} else { // it is an operand, output the operand
				postfix.append(" ").append(token);
			}
		}

		// Output the remaining operators on the stack.
		while (!operatorStack.empty()) {
			String op = operatorStack.pop();
			if (op.equals("(")) {
				System.err.println("Parentheses mismatched");
				return null;
			}
			postfix.append(" ").append(op);
		}
		return postfix.toString();
	}

	public static void caSimulation(int cycles, boolean isRank,
			List<Element> eleList, List<ExecRules> rule,
			Map<String, Element> eleMap,
			Map<Integer, List<ExecRules>> rankRuleLst) {
		for (int i = 0; i < cycles; i++) {
			// toggle
			for (Element ele : eleList)
				ele.toggle(i);
			if (isRank) {
				Object[] keyArr = rankRuleLst.keySet().toArray();
				Arrays.sort(keyArr);
				for (int k = 0; k < keyArr.length; k++) {
					List<ExecRules> tmpER = rankRuleLst.get(keyArr[k]);
					Collections.shuffle(tmpER);
					for (ExecRules er : tmpER) {
						evalRule(er, eleMap);
					}
				}

			} else { // no rank
				List<ExecRules> tmpR = new ArrayList<ExecRules>(rule);
				Collections.shuffle(tmpR);
				for (ExecRules er : tmpR) {
					evalRule(er, eleMap);
				}
			}
			for (Element ele : eleList) {
				ele.updateRound();
				ele.updateAccum();
			}
		}
	}

	public static ExecRules samplingRules(List<Double> accProb,
			List<ExecRules> orderRuleLst) {
		double ranNum = Math.random();
		// System.out.println(ranNum);
		int start = 0;
		int end = accProb.size() - 1;
		while (start <= end) {
			int mid = (start + end) / 2;
			if (ranNum < accProb.get(mid))
				end = mid - 1;
			else if (ranNum > accProb.get(mid))
				start = mid + 1;
			else
				return orderRuleLst.get(mid);
		}
		return orderRuleLst.get(start);
	}

	public static void raSimulation(int cycles, List<Element> eleList,
			List<ExecRules> rule, Map<String, Element> eleMap, int probVer,
			List<Double> accProb, List<ExecRules> orderRuleLst) {
		// no need to implement rank function
		for (int i = 0; i < cycles; i++) {
			// toggle
			for (Element ele : eleList) {
				ele.toggle(i);
			}
			ExecRules tmpRule;
			if (probVer == 0)
				tmpRule = rule.get((int) (Math.random() * rule.size()));
			else
				tmpRule = samplingRules(accProb, orderRuleLst);
			// System.out.println(tmpRule.getRuleLst().get(0).getRval());
			evalRule(tmpRule, eleMap);
			for (Element ele : eleList) {
				ele.updateRound();
				ele.updateAccum();
			}
		}
	}

	public static void evalRule(ExecRules er, Map<String, Element> eleMap) {
		if (er.getAsync()) {
			for (Rule rule : er.getRuleLst()) {
				Element ele = eleMap.get(rule.getLval());
				if (ele == null) {
					System.err.println("Element does not exist: "
							+ rule.getLval());
					System.exit(-1);
				}
				int val = evalExpr(rule.getRval(), eleMap);
				ele.setCurVal(val);
			}
		} else {
			Map<Element, Integer> tmpMap = new HashMap<Element, Integer>();
			for (Rule rule : er.getRuleLst()) {
				Element ele = eleMap.get(rule.getLval());
				if (ele == null) {
					System.err.println("Element does not exist: "
							+ rule.getLval());
					System.exit(-1);
				}
				int val = evalExpr(rule.getRval(), eleMap);
				tmpMap.put(ele, val);
			}
			for (Element ele : tmpMap.keySet()) {
				ele.setCurVal(tmpMap.get(ele));
			}
		}
	}

	public static boolean isOp(String op) {
		return op.equals("+") || op.equals("*") || op.equals("!");
	}

	public static int evalExpr(String expr, Map<String, Element> eleMap) {
		String[] exprArr = expr.split(" ");
		Stack<Integer> stack = new Stack<Integer>();

		for (int i = 0; i < exprArr.length; i++) {
			if (!isOp(exprArr[i])) {
				Element ele = eleMap.get(exprArr[i]);
				if (ele == null) {
					System.out.println("Element: " + exprArr[i]
							+ " doesn't exist!");
					System.exit(-1);
				}
				stack.push(ele.getCurVal());
			} else if (exprArr[i].equals("!")) {
				int op1 = stack.pop();
				int result = procOp(op1, 0, exprArr[i]);
				stack.push(result);
			} else {
				int op1 = stack.pop();
				int op2 = stack.pop();
				int result = procOp(op1, op2, exprArr[i]);
				stack.push(result);
			}
		}

		int answer = stack.pop();
		if (stack.empty())
			return answer;
		else { // shouldn't reach here
			System.err.println("ERROR!");
			System.exit(-1);
			return 0;
		}
	}

	public static int procOp(int op1, int op2, String op) {

		if (op.equals("!"))
			return op1 == 1 ? 0 : 1;
		else if (op.equals("+"))
			return (op1 + op2) > 0 ? 1 : 0;
		else if (op.equals("*"))
			return op1 * op2;
		else {
			System.err.println("Wrong operator: " + op);
			System.exit(-1);
			return 0;
		}
	}
}
