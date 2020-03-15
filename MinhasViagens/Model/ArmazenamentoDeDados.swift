//
//  ArmazenamentoDeDados.swift
//  MinhasViagens
//
//  Created by Leandro de Sousa Silva on 14/03/20.
//  Copyright © 2020 AcademyMistic. All rights reserved.
//

import UIKit

class ArmazenamentoDeDados {
    
    // MARK: Propriedades
    
    let chaveDeViagens = "locaisViagem"
    var viagens: [Dictionary<String, String>] = []
    
    // MARK: Methods
    
    func getDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    func salvarViagens(viagem: Dictionary<String, String>) {
        
        viagens = listarViagens()
        
        viagens.append(viagem)
        getDefaults().set(viagens, forKey: chaveDeViagens)
        getDefaults().synchronize()
    }
    
    func listarViagens() -> [Dictionary<String, String>] {
        let dados = getDefaults().object(forKey: chaveDeViagens)
        if let dados = dados {
            return dados as! Array
        } else {
            return []
        }
    }
    
    func removerViagens(row: Int) -> [Dictionary<String, String>] {
        var todasAsViagens = listarViagens()
        todasAsViagens.remove(at: row)
        getDefaults().set(todasAsViagens, forKey: chaveDeViagens)
        getDefaults().synchronize()
        return todasAsViagens
    }
}
