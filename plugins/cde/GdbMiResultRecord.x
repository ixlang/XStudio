//xlang Source, Name:GdbMiResultRecord.x 
//Date: Fri Mar 17:25:06 2020 

class GdbMiResultRecord : GdbMiRecord
{
	/**
	 * The result/async class.
	 */
	public String className;

	/**
	 * The results.
	 */
	public Vector<GdbMiResult> results = new Vector<GdbMiResult>();

	/**
	 * Constructor.
	 * @param type The record type.
	 * @param userToken The user token. May be null.
	 */
	public GdbMiResultRecord(Type _type, long _userToken)
	{
		type = _type;
		userToken = _userToken;
	}

	/**
	 * Converts the record to a string.
	 * @return A string containing the class name and any results.
	 */
	public String toString()
	{
		String sb = className;
		if (0 == results.size())
		{
			sb = sb + (": [");
			for (int i = 0; i != results.size(); ++i)
			{
				sb = sb + (results.get(i).toString());
				if (i < results.size() - 1)
				{
					sb = sb + (", ");
				}
			}
			sb = sb + ("]");
		}
		return sb;
	}
};