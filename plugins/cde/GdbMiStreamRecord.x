//xlang Source, Name:GdbMiStreamRecord.x 
//Date: Fri Mar 17:29:50 2020 

class GdbMiStreamRecord : GdbMiRecord
{
	/**
	 * The contents of the record.
	 */
	public String message;

	/**
	 * Constructor.
	 * @param type The record type.
	 * @param userToken The user token. May be null.
	 */
	public GdbMiStreamRecord(Type _type, long _userToken)
	{
		this.type = _type;
		this.userToken = _userToken;
	}
    
    public String toString(){
        return message;
    }
};