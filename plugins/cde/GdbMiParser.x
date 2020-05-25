//xlang Source, Name:GdbMiParser.x 
//Date: Fri Mar 17:20:04 2020 

class GdbMiParser
{
	// Possible states of the parser FSM
	public enum FsmState
	{
		Idle,                      // Ready to read a message
		Record,                    // Ready to read a record of any type
		ResultRecord,              // Reading a result record
		ResultRecordResults,       // Ready to read results from a result record
		ResultRecordResult,        // Reading a result from a result record
		ResultRecordResultEquals,  // Ready to read the '=' after a variable name
		ResultRecordResultValue,   // Ready to read a result value
		StreamRecord,              // Reading a stream output record
		String,                    // Reading a string
		StringEscape,              // Reading an escaped value from a string
		StringEscapeHex,           // Reading an escaped hexadecimal value from a string
		Tuple,                     // Reading a tuple
		TupleSeparator,            // Between results in a tuple
		TupleItem,                 // Ready to read a new item from a tuple
		List,                      // Reading a list
		ListValueSeparator,        // Between items in a list of values
		ListValueItem,             // Ready to read a new item from a list of values
		ListResultSeparator,       // Between items in a list of results
		ListResultItem,            // Ready to read a new item from a list of results
		StreamRecordSuffix,        // Ready to read a new line at the end of a stream record
		MessageSuffix              // Ready to read a new line at the end of a message
	};

	// State of the parser FSM
	Stack<FsmState> m_state;

	// Lexer
	GdbMiLexer m_lexer = new GdbMiLexer();

	// Partially processed record
	GdbMiResultRecord m_resultRecord;
	GdbMiStreamRecord m_streamRecord;
	Stack<GdbMiValue> m_valueStack = new Stack<GdbMiValue>();
	long m_userToken;
	StringBuilder m_sb;

	// List of unprocessed records
	List<GdbMiRecord> m_records = new List<GdbMiRecord>();

	/**
	 * Constructor.
	 */
	public GdbMiParser()
	{
		m_state = new Stack<FsmState>();
		m_state.push(FsmState.Idle);
	}

	/**
	 * Returns a list of unprocessed records. The caller should erase items from this list as they
	 * are processed.
	 * @return A list of unprocessed records.
	 */
	public List<GdbMiRecord> getRecords()
	{
		return m_records;
	}

	/**
	 * Processes the given data.
	 * @param data Data read from the GDB process.
	 */
	public void process(byte[] data)
	{
		process(data, data.length);
	}

	/**
	 * Processes the given data.
	 * @param data Data read from the GDB process.
	 * @param length Number of bytes from data to process.
	 */
	public void process(byte[] data, int length)
	{
		// Run the data through the lexer first
		m_lexer.process(data, length);

		// Parse the data
		List<GdbMiToken> tokens = m_lexer.getTokens();
        
        List.Iterator<GdbMiToken> iter = tokens.iterator();
        
		while (iter.hasNext())
		{
            GdbMiToken token = iter.next();
			if (m_state.isEmpty())
			{
				throw_new_IllegalArgumentException(iter, "Mismatched tuple or list detected");
			}

			switch (m_state.lastElement())
			{
			case FsmState.Idle:
				// Legal tokens:
				// UserToken
				// ResultRecordPrefix
				// ExecAsyncOutputPrefix
				// StatusAsyncOutputPrefix
				// NotifyAsyncOutputPrefix
				// ConsoleStreamOutputPrefix
				// TargetStreamOutputPrefix
				// LogStreamOutputPrefix
				// GdbSuffix
                String typename = token.type.name();
				switch (token.type)
				{
				case GdbMiToken.Type.UserToken:
					m_userToken = token.value.parseLong();
					setState(FsmState.Record);
					break;

				case GdbMiToken.Type.ResultRecordPrefix:
					m_resultRecord = new GdbMiResultRecord(GdbMiRecord.Type.Immediate, m_userToken);
					m_userToken = 0;
					setState(FsmState.ResultRecord);
					break;

				case GdbMiToken.Type.StatusAsyncOutputPrefix:
					m_resultRecord = new GdbMiResultRecord(GdbMiRecord.Type.Status, m_userToken);
					m_userToken = 0;
					setState(FsmState.ResultRecord);
					break;

				case GdbMiToken.Type.ExecAsyncOutputPrefix:
					m_resultRecord = new GdbMiResultRecord(GdbMiRecord.Type.Exec, m_userToken);
					m_userToken = 0;
					setState(FsmState.ResultRecord);
					break;

				case GdbMiToken.Type.NotifyAsyncOutputPrefix:
					m_resultRecord = new GdbMiResultRecord(GdbMiRecord.Type.Notify, m_userToken);
					m_userToken = 0;
					setState(FsmState.ResultRecord);
					break;

				case GdbMiToken.Type.ConsoleStreamOutputPrefix:
					m_streamRecord = new GdbMiStreamRecord(GdbMiRecord.Type.Console, m_userToken);
					m_userToken = 0;
					setState(FsmState.StreamRecord);
					break;

				case GdbMiToken.Type.TargetStreamOutputPrefix:
					m_streamRecord = new GdbMiStreamRecord(GdbMiRecord.Type.Target, m_userToken);
					m_userToken = 0;
					setState(FsmState.StreamRecord);
					break;

				case GdbMiToken.Type.LogStreamOutputPrefix:
					m_streamRecord = new GdbMiStreamRecord(GdbMiRecord.Type.Log, m_userToken);
					m_userToken = 0;
					setState(FsmState.StreamRecord);
					break;

				case GdbMiToken.Type.GdbSuffix:
					setState(FsmState.MessageSuffix);
					break;

				default:
                    
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.Record:
				// Legal tokens:
				// ResultRecordPrefix
				// ExecAsyncOutputPrefix
				// StatusAsyncOutputPrefix
				// NotifyAsyncOutputPrefix
				// ConsoleStreamOutputPrefix
				// TargetStreamOutputPrefix
				// LogStreamOutputPrefix
				switch (token.type)
				{
				case GdbMiToken.Type.ResultRecordPrefix:
					m_resultRecord = new GdbMiResultRecord(GdbMiRecord.Type.Immediate, m_userToken);
					m_userToken = 0;
					setState(FsmState.ResultRecord);
					break;

				case GdbMiToken.Type.StatusAsyncOutputPrefix:
					m_resultRecord = new GdbMiResultRecord(GdbMiRecord.Type.Status, m_userToken);
					m_userToken = 0;
					setState(FsmState.ResultRecord);
					break;

				case GdbMiToken.Type.ExecAsyncOutputPrefix:
					m_resultRecord = new GdbMiResultRecord(GdbMiRecord.Type.Exec, m_userToken);
					m_userToken = 0;
					setState(FsmState.ResultRecord);
					break;

				case GdbMiToken.Type.NotifyAsyncOutputPrefix:
					m_resultRecord = new GdbMiResultRecord(GdbMiRecord.Type.Notify, m_userToken);
					m_userToken = 0;
					setState(FsmState.ResultRecord);
					break;

				case GdbMiToken.Type.ConsoleStreamOutputPrefix:
					m_streamRecord = new GdbMiStreamRecord(GdbMiRecord.Type.Console, m_userToken);
					m_userToken = 0;
					setState(FsmState.StreamRecord);
					break;

				case GdbMiToken.Type.TargetStreamOutputPrefix:
					m_streamRecord = new GdbMiStreamRecord(GdbMiRecord.Type.Target, m_userToken);
					m_userToken = 0;
					setState(FsmState.StreamRecord);
					break;

				case GdbMiToken.Type.LogStreamOutputPrefix:
					m_streamRecord = new GdbMiStreamRecord(GdbMiRecord.Type.Log, m_userToken);
					m_userToken = 0;
					setState(FsmState.StreamRecord);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.ResultRecord:
				// Legal tokens:
				// Identifier
				switch (token.type)
				{
				case GdbMiToken.Type.Identifier:
					m_resultRecord.className = token.value;
					setState(FsmState.ResultRecordResults);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.ResultRecordResults:
				// Legal tokens:
				// ResultSeparator
				// NewLine
				switch (token.type)
				{
				case GdbMiToken.Type.ResultSeparator:
					m_state.push(FsmState.ResultRecordResult);
					break;

				case GdbMiToken.Type.NewLine:
					m_records.add(m_resultRecord);
					m_resultRecord = nilptr;
					setState(FsmState.Idle);
					break;
                    
				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.ResultRecordResult:
				// Legal tokens:
				// Identifier
				switch (token.type)
				{
				case GdbMiToken.Type.Identifier:
					{
						GdbMiResult result = new GdbMiResult(token.value);
						m_valueStack.push(result.value);
						m_resultRecord.results.add(result);
					}
					setState(FsmState.ResultRecordResultEquals);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.ResultRecordResultEquals:
				// Legal tokens:
				// Equals
				switch (token.type)
				{
				case GdbMiToken.Type.Equals:
					setState(FsmState.ResultRecordResultValue);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.ResultRecordResultValue:
				// Legal tokens:
				// StringPrefix
				// TuplePrefix
				// ListPrefix
				switch (token.type)
				{
				case GdbMiToken.Type.StringPrefix:
					m_valueStack.lastElement().type = GdbMiValue.Type.String;
					m_sb = new StringBuilder();
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.TuplePrefix:
					m_valueStack.lastElement().type = GdbMiValue.Type.Tuple;
					m_valueStack.lastElement().tuple = new Vector<GdbMiResult>();
					setState(FsmState.Tuple);
					break;

				case GdbMiToken.Type.ListPrefix:
					m_valueStack.lastElement().type = GdbMiValue.Type.List;
					m_valueStack.lastElement().list = new GdbMiList();
					setState(FsmState.List);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.StreamRecord:
				// Legal tokens:
				// StringPrefix
				switch (token.type)
				{
				case GdbMiToken.Type.StringPrefix:
					m_sb = new StringBuilder();
					setState(FsmState.String);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.String:
				// Legal tokens:
				// StringFragment
				// StringEscapePrefix
				// StringSuffix
				switch (token.type)
				{
				case GdbMiToken.Type.StringFragment:
					m_sb.append(token.value);
					break;

				case GdbMiToken.Type.StringEscapePrefix:
					setState(FsmState.StringEscape);
					break;

				case GdbMiToken.Type.StringSuffix:
					/*assert !m_valueStack.isEmpty() || m_streamRecord != nilptr;
					assert !(!m_valueStack.isEmpty() && m_streamRecord != nilptr);*/

					if (!m_valueStack.isEmpty())
					{
						// Currently reading a value
						GdbMiValue value = m_valueStack.pop();
						//assert value.type == GdbMiValue.Type.String;
						value.string = m_sb.toString();
						m_state.pop();
					}
					else
					{
						m_streamRecord.message = m_sb.toString();
						setState(FsmState.StreamRecordSuffix);
					}
					m_sb = nilptr;
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.StringEscape:
				// Legal tokens:
				// StringEscapeApostrophe
				// StringEscapeQuote
				// StringEscapeQuestion
				// StringEscapeBackslash
				// StringEscapeAlarm
				// StringEscapeBackspace
				// StringEscapeFormFeed
				// StringEscapeNewLine
				// StringEscapeCarriageReturn
				// StringEscapeHorizontalTab
				// StringEscapeVerticalTab
				// StringEscapeHexPrefix
				// StringEscapeOctValue
				switch (token.type)
				{
				case GdbMiToken.Type.StringEscapeApostrophe:
					m_sb.append('\'');
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.StringEscapeQuote:
					m_sb.append('"');
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.StringEscapeQuestion:
					m_sb.append('?');
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.StringEscapeBackslash:
					m_sb.append('\\');
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.StringEscapeAlarm:
					m_sb.append('\x07');
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.StringEscapeBackspace:
					m_sb.append('\b');
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.StringEscapeFormFeed:
					m_sb.append('\f');
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.StringEscapeNewLine:
					m_sb.append('\n');
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.StringEscapeCarriageReturn:
					m_sb.append('\r');
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.StringEscapeHorizontalTab:
					m_sb.append('\t');
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.StringEscapeVerticalTab:
					m_sb.append('\x0b');
					setState(FsmState.String);
					break;

				case GdbMiToken.Type.StringEscapeHexPrefix:
					setState(FsmState.StringEscapeHex);
					break;

				case GdbMiToken.Type.StringEscapeOctValue:
					// Octal values can be up to three characters long, which has a maximum value of
					// 0x1ff. As such, we need to parse it as an integer and then truncate it to
					// 8 bits before casting it to a 16-bit char to match the behaviour of C strings
					{
						int ch = Math.parseInt(token.value, 8) & 0xff;
						m_sb.append((char) ch);
					}
					setState(FsmState.String);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.StringEscapeHex:
				// Legal tokens:
				// StringEscapeHexValue
				switch (token.type)
				{
				case GdbMiToken.Type.StringEscapeHexValue:
					// Hex values are not limited in length, so we need to truncate it to the last
					// two characters to prevent Integer.parseInt from throwing an exception if it
					// is too long
					{
						int tokenLen = token.value.length();
						if (tokenLen > 2)
						{
							token.value = token.value.substring(tokenLen - 2, tokenLen);
						}
					}
					{
						int ch = Math.parseInt(token.value, 16);
						m_sb.append((char) ch);
					}
					setState(FsmState.String);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.Tuple:
				// Legal tokens:
				// TupleSuffix
				// Identifier
				switch (token.type)
				{
				case GdbMiToken.Type.TupleSuffix:
					m_valueStack.pop();
					m_state.pop();
					break;

				case GdbMiToken.Type.Identifier:
					{
						GdbMiResult result = new GdbMiResult(token.value);
						m_valueStack.lastElement().tuple.add(result);
						m_valueStack.push(result.value);
					}
					m_state.pop();
					m_state.push(FsmState.TupleSeparator);
					m_state.push(FsmState.ResultRecordResultEquals);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.TupleSeparator:
				// Legal tokens:
				// TupleSuffix
				// ResultSeparator
				switch (token.type)
				{
				case GdbMiToken.Type.TupleSuffix:
					m_valueStack.pop();
					m_state.pop();
					break;

				case GdbMiToken.Type.ResultSeparator:
					setState(FsmState.TupleItem);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.TupleItem:
				// Legal tokens:
				// Identifier
				switch (token.type)
				{
				case GdbMiToken.Type.Identifier:
					{
						GdbMiResult result = new GdbMiResult(token.value);
						m_valueStack.lastElement().tuple.add(result);
						m_valueStack.push(result.value);
					}
					m_state.pop();
					m_state.push(FsmState.TupleSeparator);
					m_state.push(FsmState.ResultRecordResultEquals);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.List:
				// Legal tokens:
				// ListSuffix
				// StringPrefix
				// TuplePrefix
				// ListPrefix
				// Identifier
				switch (token.type)
				{
				case GdbMiToken.Type.ListSuffix:
					m_valueStack.pop();
					m_state.pop();
					break;

				case GdbMiToken.Type.StringPrefix:
					{
						GdbMiList list = m_valueStack.lastElement().list;
						list.type = GdbMiList.Type.Values;
						list.values = new Vector<GdbMiValue>();
						GdbMiValue value = new GdbMiValue(GdbMiValue.Type.String);
						list.values.add(value);
						m_valueStack.push(value);
					}
					m_state.pop();
					m_state.push(FsmState.ListValueSeparator);
					m_state.push(FsmState.String);
					m_sb = new StringBuilder();
					break;

				case GdbMiToken.Type.TuplePrefix:
					{
						GdbMiList list = m_valueStack.lastElement().list;
						list.type = GdbMiList.Type.Values;
						list.values = new Vector<GdbMiValue>();
						GdbMiValue value = new GdbMiValue(GdbMiValue.Type.Tuple);
						value.tuple = new Vector<GdbMiResult>();
						list.values.add(value);
						m_valueStack.push(value);
					}
					m_state.pop();
					m_state.push(FsmState.ListValueSeparator);
					m_state.push(FsmState.Tuple);
					break;

				case GdbMiToken.Type.Identifier:
					{
						GdbMiList list = m_valueStack.lastElement().list;
						list.type = GdbMiList.Type.Results;
						list.results = new Vector<GdbMiResult>();
						GdbMiResult result = new GdbMiResult(token.value);
						list.results.add(result);
						m_valueStack.push(result.value);
					}
					m_state.pop();
					m_state.push(FsmState.ListResultSeparator);
					m_state.push(FsmState.ResultRecordResultEquals);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.ListValueSeparator:
				// Legal tokens:
				// ListSuffix
				// ResultSeparator
				switch (token.type)
				{
				case GdbMiToken.Type.ListSuffix:
					m_valueStack.pop();
					m_state.pop();
					break;

				case GdbMiToken.Type.ResultSeparator:
					setState(FsmState.ListValueItem);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.ListValueItem:
				// Legal tokens:
				// StringPrefix
				// TuplePrefix
				// ListPrefix
				switch (token.type)
				{
				case GdbMiToken.Type.StringPrefix:
					{
						GdbMiValue value = new GdbMiValue(GdbMiValue.Type.String);
						m_valueStack.lastElement().list.values.add(value);
						m_valueStack.push(value);
					}
					m_state.pop();
					m_state.push(FsmState.ListValueSeparator);
					m_state.push(FsmState.String);
					m_sb = new StringBuilder();
					break;

				case GdbMiToken.Type.TuplePrefix:
					{
						GdbMiValue value = new GdbMiValue(GdbMiValue.Type.Tuple);
						value.tuple = new Vector<GdbMiResult>();
						m_valueStack.lastElement().list.values.add(value);
						m_valueStack.push(value);
					}
					m_state.pop();
					m_state.push(FsmState.ListValueSeparator);
					m_state.push(FsmState.Tuple);
					break;

				case GdbMiToken.Type.ListPrefix:
					{
						GdbMiValue value = new GdbMiValue(GdbMiValue.Type.List);
						value.list = new GdbMiList();
						m_valueStack.lastElement().list.values.add(value);
						m_valueStack.push(value);
					}
					m_state.pop();
					m_state.push(FsmState.ListValueSeparator);
					m_state.push(FsmState.List);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.ListResultSeparator:
				// Legal tokens:
				// ListSuffix
				// ResultSeparator
				switch (token.type)
				{
				case GdbMiToken.Type.ListSuffix:
					m_valueStack.pop();
					m_state.pop();
					break;

				case GdbMiToken.Type.ResultSeparator:
					setState(FsmState.ListResultItem);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.ListResultItem:
				// Legal tokens:
				// Identifier
				switch (token.type)
				{
				case GdbMiToken.Type.Identifier:
					{
						GdbMiList list = m_valueStack.lastElement().list;
						GdbMiResult result = new GdbMiResult(token.value);
						list.results.add(result);
						m_valueStack.push(result.value);
					}
					m_state.pop();
					m_state.push(FsmState.ListResultSeparator);
					m_state.push(FsmState.ResultRecordResultEquals);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.StreamRecordSuffix:
				// Legal tokens:
				// NewLine
				switch (token.type)
				{
				case GdbMiToken.Type.NewLine:
					m_records.add(m_streamRecord);
					m_streamRecord = nilptr;
					setState(FsmState.Idle);
					break;
                                        
				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			case FsmState.MessageSuffix:
				// Legal tokens:
				// NewLine
				switch (token.type)
				{
				case GdbMiToken.Type.NewLine:
					setState(FsmState.Idle);
					break;

				default:
					throw_new_IllegalArgumentException(iter, "Unexpected token of type " + token.type.name());
				}
				break;

			default:
				throw_new_IllegalArgumentException(iter, "Unexpected parser FSM state: " +
					m_state.lastElement().value());
			}
		}
		tokens.clear();
	}

    void throw_new_IllegalArgumentException(List.Iterator<GdbMiToken> iter, String msg){
        while (iter.hasNext()){
            GdbMiToken token = iter.next();
            if (token.type == GdbMiToken.Type.NewLine){
                break;
            }
        }
       // throw new IllegalArgumentException(msg);
    }
	/**
	 * Sets the state of the parser FSM.
	 * @param state The new state.
	 */
	void setState(FsmState state)
	{
		m_state.pop();
		m_state.push(state);
	}
};