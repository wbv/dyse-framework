import java.util.List;
import java.util.ArrayList;

public class ExecRules {
	private List<Rule> ruleLst;
	private boolean async;

	public ExecRules(boolean async) {
		ruleLst = new ArrayList<Rule>();
		this.async = async;
	}

	public List<Rule> getRuleLst() {
		return ruleLst;
	}

	public boolean getAsync() {
		return async;
	}

	public void addRule(Rule rule) {
		ruleLst.add(rule);
	}

	public void setAsync(boolean async) {
		this.async = async;
	}
}
