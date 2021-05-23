//
//  ViewController.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 23.05.2021.
//

import UIKit
import CoreApi

class ViewController: UIViewController {
    let networkManager: NetworkManager<HomeEndpointItem> = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        networkManager.request(endpoint: .gamesList, type: GameListResponse.self) { result in
            switch result {
            case .success(let response):
                print(response)
                break
            case .failure(let error):
                print(error.message)
                break
            }
        }
    }

}

