function applysetsquare(obj, Frequency, Amplitude, Offset)

libname = get(get(obj, 'Parent'), 'DriverName');
session = get(get(obj, 'Parent'), 'Interface');

status = calllib(libname, 'Ag33220_ApplySetSquare', session, Frequency, Amplitude, Offset);


if (status < 0)
	errorMessage = libpointer('int8Ptr', repmat(10, 1, 512));
	status = calllib(libname, 'Ag33220_error_message', session, status, errorMessage);

	if (status < 0)
		error('Failed to interpret error message');
	end

	errorMessage = strtrim(char(errorMessage.Value));
	error('The instrument returned an error while executing the function.\n%s', errorMessage)
end