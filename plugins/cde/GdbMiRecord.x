//xlang Source, Name:GdbMiRecord.x 
//Date: Fri Mar 17:23:37 2020 

class GdbMiRecord
{
	/**
	 * Possible record types.
	 */
	public enum Type
	{
		Immediate,  // Result: Immediate result for the last request
		Exec,       // Result: Asynchronous state change on the target
		Status,     // Result: Progress information about a long-running operation
		Notify,     // Result: Supplementary information
		Console,    // Stream: Textual response from a CLI command to be printed to the console
		Target,     // Stream: Output from the running application
		Log         // Stream: Log output from GDB
	};

	/**
	 * The type of the record.
	 */
	public Type type;

	/**
	 * The user token from the record. May be null if none was specified.
	 */
	public long userToken;
    
    public bool processed = false;
    
    public String toString();
};