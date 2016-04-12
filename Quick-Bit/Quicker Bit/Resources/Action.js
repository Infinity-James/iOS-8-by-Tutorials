//
//  Action.js
//  Quicker Bit
//
//  Created by James Valaitis on 08/07/2015.
//  Copyright (c) 2015 Ray Wenderlich LLC. All rights reserved.
//

var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        arguments.completionFunction({ "currentURL" : document.URL })
    },
    
    finalize: function(arguments) {
		
    }
    
};
    
var ExtensionPreprocessingJS = new Action