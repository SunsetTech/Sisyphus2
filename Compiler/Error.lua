local Tools = require"Toolbox.Tools"

local Error = {}

Error.Enabled = true

function Error.Throw(Message, Offset)
	if Error.Enabled then
		error(Message, 1 + (Offset or 0))
	else
		io.write("ERROR: ", Message, "\n")
	end
end

function Error.Assert(Flag, Message, Offset)
	if (not Flag) then
		Error.Throw(Message, 1 + (Offset or 0))
	end
end

function Error.CallerAssert(Flag, Message, Offset)
	Error.Assert(Flag, Message, 2 + (Offset or 0))
end

function Error.CallerError(Message, Offset)
	Error.Throw(Message, 2 + (Offset or 0))
end

function Error.NotMine(Function, ...)
	if Error.Enabled then
		return Tools.Error.Rethrow(Function, 1, ...)
	else
		return Function(...)
	end
end

function Error.Unimplemented()
	Error.CallerError"Function not implemented"
end

return Error
