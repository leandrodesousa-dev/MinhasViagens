//
//  MapaViewController.swift
//  MinhasViagens
//
//  Created by Leandro de Sousa Silva on 08/03/20.
//  Copyright © 2020 AcademyMistic. All rights reserved.
//

import UIKit
import MapKit

class MapaViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapaView: MKMapView!
    
    // MARK: Propriedades
    
    let gerenciadorDeLocalizacao = CLLocationManager()
    var viagem: Dictionary<String, String> = [:]
    var indiceSelecionado: Int?
    
    // MARK: Ciclo de vida da view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let indice = indiceSelecionado {
            let viagens = ArmazenamentoDeDados().listarViagens()
            self.exibirAnotacao(viagem: viagens[indice])
        } else {
            configuracaoDeLocalizacao()
        }

        let reconhecedorDeGesto = UILongPressGestureRecognizer(target: self, action: #selector(gestoDeTocarNoMapa(gesture:)))
        reconhecedorDeGesto.minimumPressDuration = 1
        mapaView.addGestureRecognizer(reconhecedorDeGesto)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
    
    // MARK: Private methods
    
    fileprivate func configuracaoDeLocalizacao() {
        gerenciadorDeLocalizacao.delegate = self
        gerenciadorDeLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorDeLocalizacao.requestWhenInUseAuthorization()
        gerenciadorDeLocalizacao.startUpdatingLocation()
    }
    
    // MARK: Methods
    
    func exibirAnotacao(viagem: Dictionary<String, String>) {
        let anotacao = MKPointAnnotation()
        
        guard let latitudeString = viagem["latitude"],
            let longitudeString = viagem["longitude"],
            let local = viagem["nome"],
            let latitude = Double(latitudeString),
            let longitude = Double(longitudeString) else { return }
        
        anotacao.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        anotacao.title = local
        
        mapaView.addAnnotation(anotacao)
        setRegiao(latitude, longitude)
    }
    
    func setRegiao(_ latitude: Double, _ longitude: Double) {
        let locacalizacaoRegion = CLLocationCoordinate2DMake(latitude, longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        let regiao: MKCoordinateRegion = MKCoordinateRegion(center: locacalizacaoRegion, span: span)
        mapaView.setRegion(regiao, animated: true)
    }
    
    @objc func gestoDeTocarNoMapa(gesture: UIGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizer.State.began {
            let pontoSelecioando = gesture.location(in: self.mapaView)
            let coordenadas = mapaView.convert(pontoSelecioando, toCoordinateFrom: self.mapaView)
            
            let localizacao = CLLocation(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
            var localCompleto = "Endereço nao encontrado"
            setRegiao(coordenadas.latitude, coordenadas.longitude)
            
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
                    self.viagem = ["nome": localCompleto, "latitude": String(coordenadas.latitude), "longitude": String(coordenadas.longitude)]
                    ArmazenamentoDeDados().salvarViagens(viagem: self.viagem)
                    self.exibirAnotacao(viagem: self.viagem)
                } else {
                    print(error ?? "")
                }
                }

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
