//xlang Source, Name:GdbMiResult.x 
//Date: Fri Mar 17:28:56 2020 

class GdbMiResult
{
	/**
	 * Name of the variable.
	 */
	public String variable;

	/**
	 * Value of the variable.
	 */
	public GdbMiValue value = new GdbMiValue();

	/**
	 * Constructor.
	 * @param variable The name of the variable.
	 */
	public GdbMiResult(String _variable)
	{
		this.variable = _variable;
	}

	/**
	 * Converts the result to a string.
	 * @return A string containing the name of the variable and its value.
	 */
	public String toString()
	{
		return variable + (": ") + (value.toString());
	}
};