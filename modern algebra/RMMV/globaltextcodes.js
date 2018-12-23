//=============================================================================
//  GlobalTextCodes.js
//=============================================================================
//  Version: 1.0.2
//  Date: 21 November 2015
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*:
 * @plugindesc Use basic escape codes in any window for any text
 * @author Modern Algebra (rmrk.net)
 * @help This plugin allows you to use basic escape codes in any text field, so long 
 * as you include \* in the text field. By default, the options are limited to
 * \c[n]; \i[n]; \v[x]; \n[x]; \pn[x]; \{; \}; and \G. They may be expanded by
 * other message scripts which add escape codes, but not likely by all such
 * escape codes as some would be necessarily restricted to the message window.
 * 
 * When using codes like \c[n] and others that change the font settings,
 * remember that you should set it back to normal afterwards. In other words,
 * write "\*\c[3]Text\c[0]" and not just "\*\c[3]Text"
 */
//=============================================================================

var Imported = Imported || {};
Imported.MA_GlobalTextCodes = true;

var ModernAlgebra = ModernAlgebra || {};
ModernAlgebra.GTC = {};

(function() {
    
	// Draw Text - Check for \* and drawTextEx if it is present
	ModernAlgebra.GTC.window_Base_drawText = 
            Window_Base.prototype.drawText;
	Window_Base.prototype.drawText = function() {
		var text = arguments[0];
		if ((typeof text === 'string' || text instanceof String) && text.match(/\\\*/i)) {
			var tx = this.magtcCalculateAlignmentExX.apply(this, arguments);
			// Draw Special Text if the \* code is present
			this.drawTextEx(text, tx, arguments[2]);
		} else {
			// Draw Normal Text otherwise
    		ModernAlgebra.GTC.window_Base_drawText.apply(this, arguments);
		}
	};
	
	// Convert Escape Characters - delete \* codes
    ModernAlgebra.GTC.window_Base_convertEscapeCharacters = 
            Window_Base.prototype.convertEscapeCharacters;
    Window_Base.prototype.convertEscapeCharacters = function() {
        var text = ModernAlgebra.GTC.window_Base_convertEscapeCharacters.apply(this, arguments)
        text = text.replace(/\x1b\*/, ''); // Remove \* Codes
        return text;
    };
	
	// Calculate Alignment Ex X - Get display X when using different alignment
	Window_Base.prototype.magtcCalculateAlignmentExX = function(text, tx, y, mw, align) {
		if (align === 'center' || align === 'right') {
			// Calculate line length and adjust x based on alignment
			var tw = this.magtcMeasureTextEx(text);
			var blankSpace = mw - tw;
			if (align === 'center') {
				blankSpace = blankSpace / 2;
			}
			tx = tx + blankSpace;
		}
		return tx
	};
	
	// Measure text that has escape codes
	Window_Base.prototype.magtcMeasureTextEx = function(text) {
		// Create temporary bitmap for testing to accomodate other scripts with unknown codes
		this._magtcAlignmentTesting = true;
		var realContents = this.contents;
		this.contents = new Bitmap(24, 24);
		this.resetFontSettings();
		// Draw TextEx on the temporary Bitmap
		var firstLine = text.match(/^\n?(.+)\n?/)[0] || '';
		var tw = this.drawTextEx(firstLine, 0, 0);
		// Restore normal contents
		this._magtcAlignmentTesting = null;
		this.contents = realContents;
		return tw
	}
	
})();