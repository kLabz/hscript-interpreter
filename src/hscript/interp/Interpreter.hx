package hscript.interp;

import haxe.io.Eof;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

import hscript.Expr.Error;
import hscript.Parser;
import hscript.Interp;
import hscript.interp.Utils.numberLines;
import hxargs.Args;

enum Command {
	PrintHelp;
	Execute(script:String);
}

class Interpreter {
	public static function main():Void new Interpreter();

	function new() {
		var command:Command = PrintHelp;

		var argHandler = Args.generate([
			@doc("Display this help message")
			["--help", "-h"] => () -> command = PrintHelp,

			_ => (script:String) -> command = Execute(script)
		]);

		try argHandler.parse(Sys.args())
		catch (err:String) { return execute(Sys.args()[0]); }
		catch (err:Eof) {}

		switch (command) {
			case PrintHelp:
				Sys.println("HScript interpreter");
				Sys.println("");
				Sys.println(argHandler.getDoc());

			case Execute(script):
				execute(script);
		}
	}

	static function execute(path:String) {
		var abspath = StringTools.startsWith(path, '/') ? path : Path.join([Sys.getCwd(), path]);

		if (FileSystem.exists(abspath)) {
			var interp = new Interp();
			var contents = File.getContent(abspath);
			// Escape shebang
			if (contents.charAt(0) == "#") contents = "//" + contents;

			try {
				var parser = new Parser();
				var expr = parser.parseString(contents, path);

				interp.variables.set("Date", Date);
				interp.variables.set("DateTools", DateTools);
				interp.variables.set("EReg", EReg);
				interp.variables.set("Lambda", Lambda);
				interp.variables.set("Math", Math);
				interp.variables.set("StringBuf", StringBuf);
				interp.variables.set("StringTools", StringTools);

				interp.variables.set("Json", haxe.Json);
				interp.variables.set("Timer", haxe.Timer);
				interp.variables.set("Path", haxe.io.Path);
				interp.variables.set("Bytes", haxe.io.Bytes);

				interp.variables.set("Sys", Sys);
				interp.variables.set("Http", sys.Http);
				interp.variables.set("FileSystem", sys.FileSystem);
				interp.variables.set("File", sys.io.File);
				interp.variables.set("Process", sys.io.Process);
				interp.execute(expr);
			} catch (err:Error) {
				Console.error("HScript error:");
				Console.printlnFormatted(numberLines(contents, err, 0));
			} catch (e:Dynamic) {
				var expr = @:privateAccess interp.curExpr;
				var err = new Error(ECustom(e), expr.pmin, expr.pmax, expr.origin, expr.line);
				Console.error("HScript runtime error:");
				Console.printlnFormatted(numberLines(contents, err, 0));
			}
		}
	}
}
