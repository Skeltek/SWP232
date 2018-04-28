import Foundation

class Gamestate : NSCoding {
    
    // Entweder setzen oder raten
    var gameStatus = "setzen"
    // Ratezahl oder gesetzte Zahl des Spielers
    var number = -1
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(gameStatus, forKey: "gameStatus")
        aCoder.encode(number, forKey: "number")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.gameStatus = aDecoder.decodeObject(forKey: "gameStatus") as! String
        self.number = aDecoder.decodeObject(forKey: "number") as! Int
    }
    
    
    
    
    
}
