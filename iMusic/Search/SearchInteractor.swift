//
//  SearchInteractor.swift
//  iMusic
//
//  Created by Arkasha Zuev on 22.10.2020.
//  Copyright (c) 2020 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic {
    func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {
    
    var networkService = NetworkService()
    var presenter: SearchPresentationLogic?
    var service: SearchService?
    
    func makeRequest(request: Search.Model.Request.RequestType) {
        if service == nil {
            service = SearchService()
        }
        
        switch request {
        case .getTracks(searchTerm: let searchTerm):
            networkService.fetchTracks(searchText: searchTerm) { [weak self] (searchResponse) in
                self?.presenter?.presentData(response: Search.Model.Response.ResponseType.presentFooterView)
                self?.presenter?.presentData(response: Search.Model.Response.ResponseType.presentTracks(searchResponse: searchResponse))
            }
        }
    }
    
}
