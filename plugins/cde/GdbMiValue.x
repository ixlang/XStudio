//xlang Source, Name:GdbMiValue.x 
//Date: Fri Mar 17:26:47 2020 

class GdbMiValue
{
	/**
	 * Possible types the value can take.
	 */
	public enum Type
	{
		String,
		Tuple,
		List
	};

	/**
	 * Type of the value.
	 */
	public Type type;

	/**
	 * String. Will be null if type is not String.
	 */
	public String string;

	/**
	 * Tuple. Will be null if type is not Tuple.
	 */
	public Vector<GdbMiResult> tuple;

	/**
	 * List. Will be null if type is not List.
	 */
	public GdbMiList list;

	/**
	 * Default constructor.
	 */
	public GdbMiValue()
	{
	}

	/**
	 * Constructor; sets the type only.
	 */
	public GdbMiValue(Type _type)
	{
		type = _type;
	}

	/**
	 * Converts the value to a string.
	 * @return A string containing the value.
	 */
	public String toString()
	{
		StringBuilder sb = new StringBuilder();
		switch (type)
		{
		case Type.String:
			sb.append("\"");
			sb.append(string);
			sb.append("\"");
			break;

		case type.Tuple:
			{
				sb.append("{");
				for (int i = 0; i != tuple.size(); ++i)
				{
					sb.append(tuple.get(i).toString());
					if (i < tuple.size() - 1)
					{
						sb.append(", ");
					}
				}
				sb.append("}");
			}
			break;

		case type.List:
			sb.append(list.toString());
			break;
		}
		return sb.toString();
	}
};