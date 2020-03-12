//
//  MinhasViagensViewControllerTableViewController.swift
//  MinhasViagens
//
//  Created by Leandro de Sousa Silva on 08/03/20.
//  Copyright © 2020 AcademyMistic. All rights reserved.
//

import UIKit

class MinhasViagensViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let lugaresQueViajei: [String] = ["Manaus", "Belo Horizonte", "São Paulo", "Curitiba"]
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lugaresQueViajei.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = lugaresQueViajei[indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}
