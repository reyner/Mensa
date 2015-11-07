//
//  NumberTableViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/9/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import Mensa
import UIKit.UITableView

private let numberCount = 100
private let maxFontSize = 114

protocol Object {}

extension Number: Object {}
extension PrimeFlag: Object {}

class ObjectTableViewController: TableViewController<PrimeFlag, PrimeFlagView> {
    private var objects: [PrimeFlag] = []

    override var sections: [Section<PrimeFlag>] {
        return [Section(objects)]
    }

    required init(style: UITableViewStyle) {
        for index in (1...numberCount) {
            var number = Number(index)
//            objects.append(number)
            if number.prime {
                objects.append(PrimeFlag(number: number))
            }
        }
        super.init(style: style)
    }

    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    // MARK: HostingViewController
    override static func registerViewControllers() throws {
//        try registerViewControllerClass(NumberViewController.self, forModelType: Number.self)
        try registerViewControllerClass(PrimeFlagViewController.self, forModelType: PrimeFlag.self)
    }
    
    override func variantForObject(object: PrimeFlag) -> Int {
        if object is PrimeFlag && ((object as! PrimeFlag).number.value > 30) {
            return 1
        }
        return super.variantForObject(object)
    }

    // MARK: DataMediatorDelegate
    override func didUseViewController(viewController: HostedViewController<PrimeFlag, PrimeFlagView>, withObject object: PrimeFlag) {
        if let number = object as? Number, view = viewController.view as? NumberView {
            let fontSize = CGFloat(maxFontSize - number.value)
            view.valueLabel.font = view.valueLabel.font.fontWithSize(fontSize)
        }
    }
}

class ObjectTableDataViewController: DataViewController {
    override var dataMediatedViewController: DataMediatedViewController {
        return ObjectTableViewController(style: .Plain)
    }
}
