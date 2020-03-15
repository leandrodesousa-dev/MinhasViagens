//
//  MapaViewController.swift
//  MinhasViagens
//
//  Created by Leandro de Sousa Silva on 08/03/20.
//  Copyright © 2020 AcademyMistic. All rights reserved.
//

import UIKit
import MapKit

class MapaViewController: UIViewController {
    
    @IBOutlet weak var mapaView: MKMapView!
    
    // MARK: Propriedades
    
    let gerenciadorDeLocalizacao = CLLocationManager()
    var viagem: Dictionary<String, String> = [:]
    
    // MARK: Ciclo de vida da view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuracaoDeLocalizacao()
        
        let reconhecedorDeGesto = UILongPressGestureRecognizer(target: self, action: #selector(gestoDeTocarNoMapa(gesture:)))
        reconhecedorDeGesto.minimumPressDuration = 2
        mapaView.addGestureRecognizer(reconhecedorDeGesto)
    }
    
    // MARK: Private methods
    
    fileprivate func configuracaoDeLocalizacao() {
        gerenciadorDeLocalizacao.delegate = self
        gerenciadorDeLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorDeLocalizacao.requestWhenInUseAuthorization()
        gerenciadorDeLocalizacao.startUpdatingLocation()
    }
    
    // MARK: Methods
    
    @objc func gestoDeTocarNoMapa(gesture: UIGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            let pontoSelecioando = gesture.location(in: self.mapaView)
            let coordenadas = mapaView.convert(pontoSelecioando, toCoordinateFrom: self.mapaView)
            
            let anotacao = MKPointAnnotation()
            let localizacao = CLLocation(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
            var localCompleto = "Endereço nao encontrado"
            
            CLGeocoder().reverseGeocodeLocation(localizacao) { (data, error) in
                         if error == nil {
                            if let local = data?.first {
                             if let nome = local.name {
                                localCompleto = nome
                             } else {
                                 if let endereco = local.thoroughfare {
                                     localCompleto = endereco
                                 }
                             }
                             }
                         } else {
                            print(error ?? "")
                         }
                 anotacao.title = localCompleto
                self.viagem = ["nome": localCompleto, "latitude": String(coordenadas.latitude), "longitude": String(coordenadas.longitude)]
                ArmazenamentoDeDados().salvarViagens(viagem: self.viagem)
                print(ArmazenamentoDeDados().listarViagens())
                     }
            
            anotacao.coordinate.latitude = coordenadas.latitude
            anotacao.coordinate.longitude = coordenadas.longitude
           
            
            mapaView.addAnnotation(anotacao)
        }
    }
    
}

    // MARK: CLLocationManagerDelegate

extension MapaViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse {
            let alertaController = UIAlertController(title: "Permissão de localização",
                                                     message: "Necessário permissão para acesso à sua localização!! Por favor habilite.",
                                                     preferredStyle: .alert)
            let acaoConfiguracao = UIAlertAction(title: "Abrir configurações",
                                                 style: .default) { (alerta) in
                                                    if let configuracoes = NSURL(string: UIApplication.openSettingsURLString) {
                                                        UIApplication.shared.open(configuracoes as URL,
                                                                                  options: [:],
                                                                                  completionHandler: nil)
                                                    
                                                        if UIApplication.shared.canOpenURL(configuracoes as URL) {
                                                            UIApplication.shared.open(configuracoes as URL, completionHandler: { (success) in
                                                                print("Settings opened: \(success)") // Prints true
                                                            })
                                                        }
                                                    }

            }
            
            
            
            let acaoCancelar = UIAlertAction(title: "Cancelar", style: .default)
            
            alertaController.addAction(acaoConfiguracao)
            alertaController.addAction(acaoCancelar)
            
            present(alertaController, animated: true)
        }
    }
}
