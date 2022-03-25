package hscript.interp;

import hscript.Expr.Error;

class Utils {
	public static function numberLines(
		str:String,
		err:Error,
		?contextLines:Int = -1
	):String {
		var buf = new StringBuf();
		buf.add("<gray>");
		var lines = str.split("\n");
		var lineNbLen = Std.string(lines.length).length;
		var pos = 0;

		for (i => l in lines) {
			// TODO: add support for multiline error position
			if (contextLines > -1 && Math.abs(err.line - i - 1) > contextLines) {
				pos += l.length + 1;
				continue;
			}

			buf.add(pad(i + 1, lineNbLen, " "));
			buf.add(": ");

			if (err == null || err.line != i + 1) buf.add(l);
			else {
				var len = l.length;
				var pmin = err.pmin - pos;
				var pmax = err.pmax - pos;

				if (pmin < 0 || pmin > len || pmax > len || pmax < 0) {
					// Ignore position
					buf.add(l);
				} else {
					if (pmin > 0) buf.add(l.substring(0, pmin));
					buf.add('<white>');
					buf.add(l.substring(pmin, pmax + 1));
					buf.add('</white>');
					buf.add(l.substring(pmax + 1));
				}

				buf.add("\n<white>");
				buf.add(repeat(" ", lineNbLen - 1));
				buf.add("→ <red>");

				var errMsg = Printer.errorToString(err);
				errMsg = errMsg.substring(errMsg.indexOf(':', errMsg.indexOf(':') + 1) + 2);

				buf.add(errMsg);
				buf.add('</red></white>');
			}

			pos += l.length + 1;
			buf.add("\n");
		}

		buf.add("</gray>");
		return buf.toString();
	}

	static function repeat(s:String, times:Int, ?buf:StringBuf):String {
		var buf = buf != null ? buf : new StringBuf();
		for (_ in 0...times) buf.add(s);
		return buf.toString();
	}

	static function pad(i:Int, ?digits:Int = 2, ?char:String = "0", ?buf:StringBuf):String {
		var buf = buf != null ? buf : new StringBuf();
		while (--digits > 0 && i < Math.pow(10, digits)) buf.add(char);
		buf.add(Std.string(i));
		return buf.toString();
	}
}
