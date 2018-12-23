//=============================================================================
//  Geomancy.js
//=============================================================================
//  Version: 1.0.1
//  Date: 31 October 2015
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*:
 * @plugindesc Set terrain and region restrictions on skill use
 * @author Modern Algebra (rmrk.net)
 * @help To set up a skill so that it can only be used in certain terrains, you 
 * need to put one of the following codes in its notebox:
 * 
 * 		<onlyTerrains:x>
 * 		<prohibitedTerrains:y>
 * 
 * If you use the onlyTerrains code, then the skill can be used only on terrains
 * with ID x. If you use the prohibitedTerrains code, then the skill can only be
 * used if the party is not on the terrain with ID y. In both cases, x and y 
 * must be set to integers. You can set as many terrain tags as you want; just
 * separate them with a space or a comma.
 * 
 * The region codes work essentially the same way.
 * 
 * 		<onlyRegions:x>
 * 		<prohibitedRegions:x>
 * 
 * Examples:
 * 
 * 		<onlyRegions:1 3 4 76>
 * 			The skill can only be used when the party is in regions 1, 3, 4, or 76
 * 
 * 		<prohibitedRegions:5 10>
 * 			The skill can be used in every region except regions 5 and 10
 * 
 * 		<onlyTerrains:7>
 * 			The skill can only be used on tiles marked with terrain tag 7.
 */
//=============================================================================

(function() {
	
	// Game_BattlerBase - meetsSkillConditions
	//   Test terrain and region too
	var _mag_Game_BattlerBase_meetsSkillConditions = 
			Game_BattlerBase.prototype.meetsSkillConditions;
	Game_BattlerBase.prototype.meetsSkillConditions = function(skill) {
		var skillTest = _mag_Game_BattlerBase_meetsSkillConditions.apply(this, arguments);
		if (!skillTest || DataManager.isBattleTest()) { return skillTest; }
		return this.magMeetsSkillTerrainConditions(skill);
	};
	
	// Game_BattlerBase - Test terrain and region conditions for skills
	Game_BattlerBase.prototype.magMeetsSkillTerrainConditions = function(skill) {
		var terrainTag = $gamePlayer.terrainTag();
		var regionId = $gamePlayer.regionId();
		var rpatt = /\d+/g
		// Can't use if on an expressly prohibited terrain
		var prohibitedTerrains = skill.meta.prohibitedTerrains;
		if (prohibitedTerrains) {
			var match = prohibitedTerrains.match(rpatt);
			if (match && match.map(Number).contains(terrainTag)) { return false; }
		}
		// Can't use if in an expressly prohibited region
		var prohibitedRegions = skill.meta.prohibitedRegions;
		if (prohibitedRegions) {
			var match = prohibitedRegions.match(rpatt);
			if (match && match.map(Number).contains(regionId)) { return false; }
		}
		// Can't use if exclusive terrains defined and not on one
		var onlyTerrains = skill.meta.onlyTerrains;
		if (onlyTerrains) {
			var match = onlyTerrains.match(rpatt);
			if (match && !match.map(Number).contains(terrainTag)) { return false; }
		}
		// Can't use if exclusive regions defined and not in one
		var onlyRegions = skill.meta.onlyRegions;
		if (onlyRegions) {
			var match = onlyRegions.match(rpatt);
			if (match && !match.map(Number).contains(regionId)) { return false; }
		}
		return true; // Can use the skill otherwise
	};
	
})();