//=============================================================================
//  Vehicle Passability for Events
//  Version: 1.0.0
//  Date: 27 October 2015 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*:
 * @plugindesc Set up events that are bound by the passability rules of boats, ships, or airships
 * @author Modern Algebra (rmrk.net)
 * @help This plugin does not have any plugin parameters. It is setup through
 * comments in an event.
 * 
 * To set vehicle passability for an event, you must set the first command for
 * an event page to be a comment which includes one of the following codes:
 * 
 *      \vehicle[boat]
 *      \vehicle[ship]
 *      \vehicle[airship]
 * 
 * The vehicle type is determined on a page-by-page basis. If a vehicle event 
 * should update to a new page, it will need to have a new vehicle code or 
 * else it will revert to normal passability.
 */
//=============================================================================

(function() {
    
    var _Game_Event_initMembers =
            Game_Event.prototype.initMembers;
    Game_Event.prototype.initMembers = function() {
        _Game_Event_initMembers.call(this);
        this._maVehicleType = ''; // Initialize _maVehicleType
    };

    var _Game_Event_setupPageSettings = 
            Game_Event.prototype.setupPageSettings;
    Game_Event.prototype.setupPageSettings = function() {
        _Game_Event_setupPageSettings.call(this)
        var comments = this.maepoCollectCommentsAt(0);
        // Match an integer in \vehicle[x]
        var rpatt = /\\vehicle\s*\[\s*(boat|ship|airship)\s*\]/i;
        var match = rpatt.exec(comments);
        if (match) { // If there is a match (match is not null)
            vtype = match[1].toLowerCase();
            this._maVehicleType = vtype;
        } else {
            this._maVehicleType = '';    
        }
    };
    
    // Selects all comment lines at index i in the list
    Game_Event.prototype.maepoCollectCommentsAt = function(i) {
        var comments = '';
        var list = this.list(); // List of event commands for current page
        // Select only comment lines
        while (i < list.length && (list[i].code === 108 || list[i].code === 408)) {
            comments = comments + list[i].parameters[0];
            i++;
        }
        return comments
    };

    // For consistency, code below uses same structure as in Game_Player
    var _Game_Event_isMapPassable = 
            Game_Event.prototype.isMapPassable;   
    Game_Event.prototype.isMapPassable = function(x, y, d) {
        var vehicle = this.vehicle();
        if (vehicle) {
            return vehicle.isMapPassable(x, y, d);
        } else {
            return _Game_Event_isMapPassable.call(this, x, y, d);
        }
    };
    
    Game_Event.prototype.vehicle = function() {
        return $gameMap.vehicle(this._maVehicleType);
    };
    
})();