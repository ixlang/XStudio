//xlang Source, Name:GdbMiLexer.x 
//Date: Fri Mar 17:10:49 2020 

class GdbMiLexer
{
	// Possible states for the lexer FSM
	enum FsmState
	{
		Idle,                  // Ready to read a new token
		UserToken,             // Reading a user-token
		Identifier,            // Reading an identifier
		CString,               // Reading a C string
		CStringEscape,         // Reading a C string escape sequence
		CStringEscapeHexHead,  // Ready to read the first digit from a hexadecimal escape sequence
		CStringEscapeHex,      // Reading a hexadecimal escape sequence
		CStringEscapeOct1,     // Read the first character of an octal escape sequence
		CStringEscapeOct2,     // Read the second character of an octal escape sequence
		GdbSuffix1,            // Partially read GDB suffix "("
		GdbSuffix2,            // Partially read GDB suffix "(g"
		GdbSuffix3,            // Partially read GDB suffix "(gd"
		GdbSuffix4,            // Partially read GDB suffix "(gdb"
		GdbSuffix5,            // Read GDB suffix
		CrLf                   // Ready to optionally read LF
	};

	// State of the lexer FSM
	FsmState m_state = FsmState.Idle; 

	// Temporary store for partially read tokens
	StringBuilder m_partialToken; 

	// List of unprocessed tokens
	List<GdbMiToken> m_tokens = new List<GdbMiToken>();

	/**
	 * Returns a list of unprocessed tokens. The caller should erase items from this list as they
	 * are processed.
	 * @return A list of unprocessed tokens.
	 */
	public @NotNilptr List<GdbMiToken> getTokens()
	{
		return m_tokens;
	}

	/**
	 * Processes the given data.
	 * @param data Data read from the GDB process.
	 * @param length Number of bytes from data to process.
	 */
	public void process(byte[] data, int length) throws IllegalArgumentException
	{
		for (int i = 0; i != length; ++i)
		{
			switch (m_state)
			{
			case FsmState.Idle:
				// Legal tokens:
				// User token (digits)
				// ^, *, +, =, ~, @, &, ,, ", {, }, [, ]
				// Identifier (string)
				// CRLF
				// "(gdb)"
				switch (data[i])
				{
				case '0':
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
				case '8':
				case '9':
					m_partialToken = new StringBuilder( "" + (char) data[i]);
					m_state = FsmState.UserToken;
					break;

				case '^':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.ResultRecordPrefix));
					break;

				case '*':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.ExecAsyncOutputPrefix));
					break;

				case '+':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StatusAsyncOutputPrefix));
					break;

				case '=':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.NotifyAsyncOutputPrefix));
					break;

				case '~':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.ConsoleStreamOutputPrefix));
					break;
                    
				case '&':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.LogStreamOutputPrefix));
					break;

				case ',':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.ResultSeparator));
					break;

				case '"':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringPrefix));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case '{':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.TuplePrefix));
					break;

				case '}':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.TupleSuffix));
					break;

				case '[':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.ListPrefix));
					break;

				case ']':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.ListSuffix));
					break;

				case '(':
					m_state = FsmState.GdbSuffix1;
					break;

				case '\r':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.NewLine));
					m_state = FsmState.CrLf;
					break;

				case '_':
				case 'a':
				case 'b':
				case 'c':
				case 'd':
				case 'e':
				case 'f':
				case 'g':
				case 'h':
				case 'i':
				case 'j':
				case 'k':
				case 'l':
				case 'm':
				case 'n':
				case 'o':
				case 'p':
				case 'q':
				case 'r':
				case 's':
				case 't':
				case 'u':
				case 'v':
				case 'w':
				case 'x':
				case 'y':
				case 'z':
				case 'A':
				case 'B':
				case 'C':
				case 'D':
				case 'E':
				case 'F':
				case 'G':
				case 'H':
				case 'I':
				case 'J':
				case 'K':
				case 'L':
				case 'M':
				case 'N':
				case 'O':
				case 'P':
				case 'Q':
				case 'R':
				case 'S':
				case 'T':
				case 'U':
				case 'V':
				case 'W':
				case 'X':
				case 'Y':
				case 'Z':
					m_partialToken = new StringBuilder("" + (char) data[i]);
					m_state = FsmState.Identifier;
					break;
                case '\n':
                    m_tokens.add(new GdbMiToken(GdbMiToken.Type.NewLine));
                    m_state = FsmState.Idle;
					break;
				default:
				case '@':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.TargetStreamOutputPrefix));
					break;
				}
				break;

			case FsmState.UserToken:
				// Legal tokens:
				// User token (digits)
				// Anything else is reprocessed
				switch (data[i])
				{
				case '0':
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
				case '8':
				case '9':
					m_partialToken.append((char) data[i]);
					break;

				default:
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.UserToken,
						m_partialToken.toString()));
					m_state = FsmState.Idle;
					--i;
				}
				break;

			case FsmState.Identifier:
				// Legal tokens:
				// For an identifier: "_", 0-9, a-z, A-Z
				// "=" is handled specially as it means something else if not used after an
				// identifier
				// Anything else is reprocessed
				if (data[i] == '_' || data[i] == '-' ||
					(data[i] >= '0' && data[i] <= '9') ||
					(data[i] >= 'a' && data[i] <= 'z') ||
					(data[i] >= 'A' && data[i] <= 'Z'))
				{
					m_partialToken.append((char) data[i]);
				}
				else if (data[i] == '=')
				{
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.Identifier,
						m_partialToken.toString()));
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.Equals));
					m_partialToken = nilptr;
					m_state = FsmState.Idle;
				}
				else
				{
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.Identifier,
						m_partialToken.toString()));
					m_partialToken = nilptr;
					m_state = FsmState.Idle;
					--i;
				}
				break;

			case FsmState.CString:
				// Legal tokens:
				// Anything except CR or LF
				// Escape sequences:
				//   \'
				//   \"
				//   \?
				//   \\
				//   \a
				//   \b
				//   \f
				//   \n
				//   \r
				//   \t
				//   \v
				//   \[octal digits]
				//   \x[hexadecimal digits]
				switch (data[i])
				{
				case '"':
					if (m_partialToken.length() != 0)
					{
						m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringFragment,
							m_partialToken.toString()));
					}
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringSuffix));
					m_partialToken = nilptr;
					m_state = FsmState.Idle;
					break;

				case '\\':
					if (m_partialToken.length() != 0)
					{
						m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringFragment,
							m_partialToken.toString()));
					}
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapePrefix));
					m_state = FsmState.CStringEscape;
					m_partialToken = nilptr;
					break;

				case '\r':
				case '\n':
					throw new IllegalArgumentException("Unexpected character: '" + data[i] + "'");

				default:
					m_partialToken.append((char) data[i]);
				}
				break;

			case FsmState.CStringEscape:
				// Legal tokens:
				// "'", """, "?", "\", "a", "b", "f", "n", "r", "t", "v", "x", 0-7
				switch (data[i])
				{
				case '\'':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeApostrophe));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case '"':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeQuote));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case '?':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeQuestion));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case '\\':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeBackslash));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case 'a':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeAlarm));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case 'b':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeBackspace));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case 'f':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeFormFeed));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case 'n':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeNewLine));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case 'r':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeCarriageReturn));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case 't':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeHorizontalTab));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case 'v':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeVerticalTab));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					break;

				case 'x':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeHexPrefix));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CStringEscapeHexHead;
					break;

				case '0':
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
					m_partialToken = new StringBuilder();
					m_partialToken.append((char) data[i]);
					m_state = FsmState.CStringEscapeOct1;
					break;

				default:
					throw new IllegalArgumentException("Unexpected character: '" + data[i] + "'");
				}
				break;

			case FsmState.CStringEscapeHexHead:
				// Legal tokens:
				// Hex digits: 0-9, a-f, A-F
				if ((data[i] >= '0' && data[i] <= '9') ||
					(data[i] >= 'a' && data[i] <= 'f') ||
					(data[i] >= 'A' && data[i] <= 'F'))
				{
					m_partialToken.append((char) data[i]);
					m_state = FsmState.CStringEscapeHex;
				}
				else
				{
					throw new IllegalArgumentException("Unexpected character: '" + data[i] + "'");
				}
				break;

			case FsmState.CStringEscapeHex:
				// Legal tokens:
				// Hex digits: 0-9, a-f, A-F
				// Else reprocess as normal C string character
				if ((data[i] >= '0' && data[i] <= '9') ||
					(data[i] >= 'a' && data[i] <= 'f') ||
					(data[i] >= 'A' && data[i] <= 'F'))
				{
					m_partialToken.append((char) data[i]);
				}
				else
				{
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeHexValue,
						m_partialToken.toString()));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					--i;
				}
				break;

			case FsmState.CStringEscapeOct1:
				// Legal tokens:
				// Oct digits: 0-7
				// Else reprocess as normal C string character
				if (data[i] >= '0' && data[i] <= '7')
				{
					m_partialToken.append((char) data[i]);
					m_state = FsmState.CStringEscapeOct2;
				}
				else
				{
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeOctValue,
						m_partialToken.toString()));
					m_partialToken = new StringBuilder();
					m_state = FsmState.CString;
					--i;
				}
				break;

			case FsmState.CStringEscapeOct2:
				// Legal tokens:
				// Oct digits: 0-7
				// Else reprocess as normal C string character
				if (data[i] >= '0' && data[i] <= '7')
				{
					m_partialToken.append((char) data[i]);
				}
				else
				{
					--i;
				}
				m_tokens.add(new GdbMiToken(GdbMiToken.Type.StringEscapeOctValue,
					m_partialToken.toString()));
				m_partialToken = new StringBuilder();
				m_state = FsmState.CString;
				break;

			case FsmState.GdbSuffix1:
				// Read so far: "("
				switch (data[i])
				{
				case 'g':
					m_state = FsmState.GdbSuffix2;
					break;

				default:
					throw new IllegalArgumentException("Unexpected character: '" + data[i] + "'");
				}
				break;

			case FsmState.GdbSuffix2:
				// Read so far: "(g"
				switch (data[i])
				{
				case 'd':
					m_state = FsmState.GdbSuffix3;
					break;

				default:
					throw new IllegalArgumentException("Unexpected character: '" + data[i] + "'");
				}
				break;

			case FsmState.GdbSuffix3:
				// Read so far: "(gd"
				switch (data[i])
				{
				case 'b':
					m_state = FsmState.GdbSuffix4;
					break;

				default:
					throw new IllegalArgumentException("Unexpected character: '" + data[i] + "'");
				}
				break;

			case FsmState.GdbSuffix4:
				// Read so far: "(gdb"
				switch (data[i])
				{
				case ')':
					m_tokens.add(new GdbMiToken(GdbMiToken.Type.GdbSuffix));
					m_state = FsmState.GdbSuffix5;
					break;

				default:
					throw new IllegalArgumentException("Unexpected character: '" + data[i] + "'");
				}
				break;

			case FsmState.GdbSuffix5:
				// GDB seems to print a space here, even though the documentation doesn't mention
				// this. We just ignore it if it does
				switch (data[i])
				{
				case ' ':
					m_state = FsmState.Idle;
					break;

				default:
					// Reprocess the character
					--i;
					m_state = FsmState.Idle;
				}
				break;

			case FsmState.CrLf:
				// Legal tokens:
				// \n
				// If the character is not '\n' the state is changed to Idle and the character
				// reprocessed
				switch (data[i])
				{
				case '\n':
					m_state = FsmState.Idle;
					break;

				default:
					// Reprocess the character
					m_state = FsmState.Idle;
					--i;
				}
				break;

			default:
				throw new IllegalArgumentException("Unexpected lexer FSM state: " + m_state.name());
			}
		}
	}
};