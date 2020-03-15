//
//  MinhasViagensViewControllerTableViewController.swift
//  MinhasViagens
//
//  Created by Leandro de Sousa Silva on 08/03/20.
//  Copyright © 2020 AcademyMistic. All rights reserved.
//

import UIKit

class MinhasViagensViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Propiedades
    
    var lugaresQueViajei: [Dictionary<String, String>] = []
    
    // MARK: Ciclo de vida da view
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lugaresQueViajei = ArmazenamentoDeDados().listarViagens()
        tableView.reloadData()
    }
}

    // MARK: UITableViewDataSource

extension MinhasViagensViewController: UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lugaresQueViajei.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = lugaresQueViajei[indexPath.row]["nome"]
        return cell
    }
}

extension MinhasViagensViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
             lugaresQueViajei = ArmazenamentoDeDados().removerViagens(row: indexPath.row)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "verLocal", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verLocal" {
            if let controller = segue.destination as? MapaViewController,
                let indiceRecuperado = sender as? Int {
                controller.viagem = lugaresQueViajei[indiceRecuperado]
                controller.indiceSelecionado = indiceRecuperado
            }
        }
    }
}
