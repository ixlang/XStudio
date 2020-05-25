//xlang Source, Name:GdbMiToken.x 
//Date: Fri Mar 17:12:12 2020 

class GdbMiToken
{
	/**
	 * Possible token types.
	 */
	public enum Type
	{
		UserToken,                  // String of digits
		ResultRecordPrefix,         // "^"
		ExecAsyncOutputPrefix,      // "*"
		StatusAsyncOutputPrefix,    // "+"
		NotifyAsyncOutputPrefix,    // "="
		ConsoleStreamOutputPrefix,  // "~"
		TargetStreamOutputPrefix,   // "@"
		LogStreamOutputPrefix,      // "&"
		Identifier,                 // result-class or async-class
		Equals,                     // "="
		ResultSeparator,            // ","
		StringPrefix,               // """
		StringFragment,             // Part of a string
		StringEscapePrefix,         // "\"
		StringEscapeApostrophe,     // "'"
		StringEscapeQuote,          // """
		StringEscapeQuestion,       // "?"
		StringEscapeBackslash,      // "\"
		StringEscapeAlarm,          // "a"
		StringEscapeBackspace,      // "b"
		StringEscapeFormFeed,       // "f"
		StringEscapeNewLine,        // "n"
		StringEscapeCarriageReturn, // "r"
		StringEscapeHorizontalTab,  // "t"
		StringEscapeVerticalTab,    // "v"
		StringEscapeHexPrefix,      // "x"
		StringEscapeHexValue,       // 1-* hexadecimal digits
		StringEscapeOctValue,       // 1-3 octal digits
		StringSuffix,               // """
		TuplePrefix,                // "{"
		TupleSuffix,                // "}"
		ListPrefix,                 // "["
		ListSuffix,                 // "]"
		NewLine,                    // "\r" or "\r\n"
		GdbSuffix                   // "(gdb)"
	};

	/**
	 * The type of token.
	 */
	public Type type;

	/**
	 * The token value, if any.
	 */
	public String value = nilptr;

	/**
	 * Constructor; sets the values.
	 * @param type The type of the token.
	 * @param value The value of the token.
	 */
	public GdbMiToken(Type _type, String _value)
	{
		this.type = _type;
		this.value = _value;
	}

	/**
	 * Constructor; sets the type. The value is set to nilptr.
	 * @param type The type of token.
	 */
	public GdbMiToken(Type _type)
	{
		this.type = _type;
	}

	/**
	 * Converts the token to a string.
	 * @return A string containing the type and, if set, the value.
	 */
	public String toString()
	{
		String sb = type.name();
		if (value != nilptr)
		{
			sb = sb + (": ");
			sb = sb + (value);
		}
		return sb;
	}
};