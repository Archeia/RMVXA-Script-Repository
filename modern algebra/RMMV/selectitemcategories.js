//=============================================================================
//  SelectItemCategories.js
//=============================================================================
//  Version: 1.0.0
//  Date: 31 October 2015
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*:
 * @plugindesc Create additional categories for the Select Item event command
 * @author Modern Algebra (rmrk.net)
 * @help To set this script up, you first need to assign items to categories.
 * To do that, enter the following code into the notebox of an item:
 * 
 *      \select[x]
 *          x : Category ID (must be an integer greater than 0)
 * 
 * You can also set an item to more than one category by putting a space and
 * adding more category IDs.
 * 
 * Examples:
 * 
 *      \select[1]  // This item will show up in category 1.
 *      \select[3]  // This item will show up in category 3.
 *      \select[1 2 14]   // This item shows up in categories 1, 2, and 14
 * 
 * To select an item from one of these categories that you create, you need to
 * use the following plugin command
 * 
 *      MASelectItem x y
 *          x : Variable ID - integer
 *          y : Category ID - integer
 * 
 * It will then work the same way as the regular Select Item command, and the
 * ID of the item that the player selects will be assigned to the chosen
 * variable.
 * 
 * Examples:
 * 
 *      MASelectItem 4 1 
 *          // Items from Category 1 will be shown, and Variable 4 will be set 
 *          // to the ID of the item that the player selects.
 */
//=============================================================================

(function() {

    // Plugin Command : MASelectItem x y
    //      x : ID of the variable to set selection to (integer)
    //      y : ID of the category to select from (integer)
    var _ma_Game_Interpreter_pluginCommand =
            Game_Interpreter.prototype.pluginCommand;
    Game_Interpreter.prototype.pluginCommand = function(command, args) {
        _ma_Game_Interpreter_pluginCommand.call(this, command, args);
        if (command.toLowerCase() === 'maselectitem') {
            return this.maCommandSelectItemByCategory(+args[0], +args[1]);
        }
    };
    
    // Setup Select Item by Category
    Game_Interpreter.prototype.maCommandSelectItemByCategory = function(variableId, itemCategoryId) {
        if (!$gameMessage.isBusy()) {
            $gameMessage.maSelectItemByCategory(variableId, itemCategoryId)
            this.setWaitMode('message');
        }
        return false
    };
    
    // Clear - Initialize Item Category ID
    var _ma_Game_Message_clear =
            Game_Message.prototype.clear;
    Game_Message.prototype.clear = function() {
        _ma_Game_Message_clear.apply(this, arguments);
        this._maSelectItemCategoryId = 0; // Defauult is 0
    };
    
    // maSelectItemCategoryId - make category ID publicly accessible
    Game_Message.prototype.maSelectItemCategoryId = function() {
        return this._maSelectItemCategoryId;
    };
    
    // Game_Message - Setup Item by Category Selection
    Game_Message.prototype.maSelectItemByCategory = function(variableId, itemCategoryId) {
        this._itemChoiceVariableId = variableId;
        this._maSelectItemCategoryId = itemCategoryId;
    };

    // Window_EventItem includes - Include if category right and selecting by category
    var _ma_Window_EventItem_includes = 
            Window_EventItem.prototype.includes;
    Window_EventItem.prototype.includes = function(item) {
        var categoryId = $gameMessage.maSelectItemCategoryId();
        if (categoryId > 0) { // If Category ID is setup (>0)
            return (DataManager.isItem(item) && this.masicCategoryIds(item).contains(categoryId));
        } else { // Default includes method if not using category ID
            return _ma_Window_EventItem_includes.apply(this, arguments);
        }
    };
    
    // Window_EventItem masicCategoryIds - Get all categories for an item
    Window_EventItem.prototype.masicCategoryIds = function(item) {
        var arr = [];
        var match = item.note.match(/\\SELECT\s*\[((?:\s*\d+[\s,;:]*)+)\]/i); // \select[x1 x2 x3 ... xn]
        if (match) { arr = match[1].match(/\d+/g).map(Number); } // Map strings to integers
        return arr;
    }


})();