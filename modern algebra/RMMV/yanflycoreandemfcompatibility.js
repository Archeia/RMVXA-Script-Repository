//=============================================================================
//  YanflyCoreandEMFCompatibility.js
//=============================================================================
//  Version: 1.0.0
//  Date: 7 November 2015
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*:
 * @author Modern Algebra (rmrk.net)
 * @plugindesc Compatibility patch for Extra Movement Frames and Yanfly Core Engine v. 1.0.5
 * 
 * @help Place this plugin immediately below Yanfly Core Engine.
 * 
 * Yanfly Core Engine will sometimes prematurely reset the pattern of a
 * sprite, which can be noticeable when a sprite has more than 3 frames. This
 * patch reverses that change.
 */
//=============================================================================

/*
Yanfly's code was intended to ensure that an event moving at frequency 5 would 
not pause for a frame between movements. That problem might have been fixed 
before the official version of RMMV was released, since that does not appear 
to be a problem in the default code. I therefore wrote this patch to reverse 
Yanfly's changes, since the updated stopping code would sometimes prematurely 
reset the animation pattern of sprites.
*/

(function() {
    if (Imported && Imported.YEP_CoreEngine) {
        //=====================================================================
        // ** Game_CharacterBase
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // update - restore the default function
        Game_CharacterBase.prototype.update = function() {
            if (this.isStopping()) {
                this.updateStop();
            }
            if (this.isJumping()) {
                this.updateJump();
            } else if (this.isMoving()) {
                this.updateMove();
            }
            this.updateAnimation();
        };
        
        // updateMove - restore the default function
        Game_CharacterBase.prototype.updateMove = function() {
            Yanfly.Core.Game_CharacterBase_updateMove.call(this);
        }; 
    } else {
        var path = document.currentScript.src;
        var scriptName = path.substring(path.lastIndexOf('/')+1).match(/^(.+?)(\.[^.]*$|$)/)[1];
        console.log(scriptName + ' was not installed because Yanfly Core Engine is either disable or lower than this patch in the plugin list');
    }
		
})();