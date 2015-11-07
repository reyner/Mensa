//
//  ObjectCollectionViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/20/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import Mensa
import UIKit.UICollectionView

private let numberCount = 100
private let maxFontSize = 114

class ObjectCollectionViewController: CollectionViewController<Object, UIView> {
    private var objects: [Object] = []

    override var sections: [Section<Object>] {
        return [Section(objects)]
    }

    // MARK: UICollectionViewController
    required init(collectionViewLayout layout: UICollectionViewLayout) {
        for index in (1...numberCount) {
            var number = Number(index)
            objects.append(number)
            if number.prime {
                objects.append(PrimeFlag(number: number))
            }
        }
        super.init(collectionViewLayout: layout)
    }
    
    // MARK: HostingViewController
    override static func registerViewControllers() throws {
        try registerViewControllerClass(NumberViewController.self, forModelType: Number.self)
        try registerViewControllerClass(PrimeFlagViewController.self, forModelType: PrimeFlag.self)
    }

    // MARK: DataMediatorDelegate
    override func variantForObject(object: Object) -> Int {
        if object is PrimeFlag && ((object as! PrimeFlag).number.value > 30) {
            return 1
        }
        return super.variantForObject(object)
    }

    override func didUseViewController(viewController: HostedViewController<Object, UIView>, withObject object: Object) {
        if let number = object as? Number, view = viewController.view as? NumberView {
            let fontSize = CGFloat(maxFontSize - number.value)
            view.valueLabel.font = view.valueLabel.font.fontWithSize(fontSize)
        }
    }
}

class ObjectCollectionDataViewController: DataViewController {
    override var dataMediatedViewController: DataMediatedViewController {
        return ObjectCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    }
}
