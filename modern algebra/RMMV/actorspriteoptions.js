//=============================================================================
//  Actor Sprite Options
//  Version: 1.0.1
//  Date: 31 October 2015 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*:
 * @author Modern Algebra (rmrk.net)
 * 
 * @plugindesc Set the step animation, move animation, and blend type for each actor individually
 * 
 * @help With this plugin, you can set the blend type, walk animation, and step
 * animation for actors. If one of your actors is a flying creature like an 
 * angel, for instance, this script lets you set it so that he or she is still
 * beating his or her wings while the player is stationary.
 * 
 * The plugin is set up by writing the following codes in an actor's notebox.
 * 
 * To make it so that an actor is animating even when stationary, write:
 * 		\step
 * 
 * To make it so that an actor is not animating even when moving, write:
 * 		\immobile
 * 
 * To change the blend type of an actor to something else, write:
 * 		\blend[x]
 * 
 * Replace x with an integer, where the integers mean the following:
 * 		0  : Normal
 * 		1  : Additive
 * 		2  : Multiply
 * 		3  : Screen
 */
//=============================================================================

(function() {
	
	// mafsoBlendMode - Lazy Instantiation, default of 0
	Game_Actor.prototype.mafsoBlendMode = function() { 
		if (!this._mafsoBlendMode) {
			var actor = this.actor();
			if (actor) {
				var rmatch = actor.note.match(/\\BLEND\s*\[\s*(\d+)\s*\]/i); // \blend[x]
				this._mafsoBlendMode = rmatch ? +rmatch[1] : 0;
			}
		}
		return this._mafsoBlendMode || 0; 
	}
	
	// mafsoWalkAnime - Lazy Instantiation, default of true
	Game_Actor.prototype.mafsoWalkAnime = function() { 
		if (!this._mafsoWalkAnime) {
			var actor = this.actor();
			if (actor) { this._mafsoWalkAnime = !(/\\IMMOBILE/i).test(actor.note); } // \immobile
		}
		return this._mafsoWalkAnime || true; 
	}
	
	// mafsoStepAnime - Lazy Instantiation, default of false
	Game_Actor.prototype.mafsoStepAnime = function() {
		if (!this._mafsoStepAnime) {
			var actor = this.actor();
			if (actor) { this._mafsoStepAnime = (/\\STEP/i).test(actor.note); } // \step
		} 
		return this._mafsoStepAnime || false; 
	}
	
	// Set Sprite Options based on actor
	Game_Character.prototype.mafsoSetActorSpriteOptions = function(actor) {
		this.setBlendMode(actor.mafsoBlendMode()); 
		this.setWalkAnime(actor.mafsoWalkAnime()); 
		this.setStepAnime(actor.mafsoStepAnime()); 
	};	
	
	// Refresh
	var mafso_Game_Player_refresh = 
			Game_Player.prototype.refresh;
	Game_Player.prototype.refresh = function() {
		mafso_Game_Player_refresh.apply(this, arguments); // Call original method
		var actor = $gameParty.leader();
		// Set options based on lead actor
		if (actor) { this.mafsoSetActorSpriteOptions(actor); } 
	};
	
	// Game_Follower - Update
	var _mafso_Game_Follower_update =
			Game_Follower.prototype.update;
	Game_Follower.prototype.update = function() {
		_mafso_Game_Follower_update.apply(this, arguments); // Call original method
		var actor = this.actor()
		// Set options based on actor in this position
		if (actor) { this.mafsoSetActorSpriteOptions(actor); } 
	};
	
})();