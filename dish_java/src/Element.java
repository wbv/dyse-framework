import java.util.ArrayList;
import java.util.List;

public class Element {
	private boolean isToggle = false;
	private String name;
	private int toggleTime;
	private int curVal;
	private int initVal;
	private boolean isRandom = false;
	private List<Integer> roundSeries;
	private List<Integer> accumSeries;

	public Element(String line) {
		roundSeries = new ArrayList<Integer>();
		accumSeries = new ArrayList<Integer>();

		String[] tmpArr = line.split("=");
		name = tmpArr[0].trim();
		if (tmpArr[1].trim().contains(" ")) {// contain toggle
			String[] tA = tmpArr[1].trim().split(" ");
			isToggle = true;
			toggleTime = Integer.parseInt(tA[1]);
			curVal = eval(tA[0]);
			initVal = curVal;
		} else {
			curVal = eval(tmpArr[1].trim());
			initVal = curVal;
		}
		roundSeries.add(initVal);
		accumSeries.add(initVal);
	}

	public void toggle(int curCycle) {
		if (isToggle && curCycle == toggleTime) {
			curVal = curVal == 0 ? 1 : 0;
		}
	}

	public void updateRound() {
		roundSeries.add(curVal);
	}

	public void updateAccum() {
		if (roundSeries.size() > accumSeries.size())
			accumSeries.add(curVal);
		else {
			int idx = roundSeries.size() - 1;
			accumSeries.set(idx, accumSeries.get(idx) + curVal);
		}
	}

	public String getName() {
		return name;
	}

	public List<Integer> getRoundSeries() {
		return roundSeries;
	}

	public List<Integer> getAccSeries() {
		return accumSeries;
	}

	public int getCurVal() {
		return curVal;
	}

	public void setCurVal(int newVal) {
		curVal = newVal;
	}

	public void reset() {
		roundSeries.clear();
		curVal = isRandom ? eval("random") : initVal;
		roundSeries.add(curVal);
		accumSeries.set(0, accumSeries.get(0) + curVal);
	}

	public int eval(String in) {
		if (in.toLowerCase().equals("true"))
			return 1;
		else if (in.toLowerCase().equals("false"))
			return 0;
		else if ((in.toLowerCase().equals("random"))) {
			isRandom = true;
			return (int) (Math.random() * 2);
		} else {
			System.err.println("Wrong initial value!");
			return -1;
		}
	}
}
