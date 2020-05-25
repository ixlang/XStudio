//xlang Source, Name:GdbMiList.x 
//Date: Fri Mar 17:27:28 2020 

class GdbMiList
{
	/**
	 * Possible types of lists. GDB/MI lists may contain either results or values, but not both. If
	 * the list is empty there is no way to know which was intended, so it is classified as a
	 * separate type. If the list is empty, both results and values will be null.
	 */
	public enum Type
	{
		Empty,
		Results,
		Values
	};

	/**
	 * The type of list.
 	 */
	public Type type = Type.Empty;

	/**
	 * List of results. This will be null if type is not Results.
	 */
	public Vector<GdbMiResult> results;

	/**
	 * List of values. This will be null if type is not Values.
	 */
	public Vector<GdbMiValue> values;

	/**
	 * Converts the list to a string.
	 * @return A string containing the contents of the list.
	 */
	public String toString()
	{
		String sb = "[";
		switch (type)
		{
		case Type.Values:
			for (int i = 0; i != values.size(); ++i)
			{
				sb = sb + (values.get(i).toString());
				if (i < values.size() - 1)
				{
					sb = sb + (", ");
				}
			}
			break;

		case Type.Results:
			for (int i = 0; i != results.size(); ++i)
			{
				sb = sb + (results.get(i).toString());
				if (i < results.size() - 1)
				{
					sb = sb + (", ");
				}
			}
			break;
		}
		sb = sb + ("]");
		return sb;
	}
};