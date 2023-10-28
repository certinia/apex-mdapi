import { LightningElement, track, wire } from 'lwc';
import retrieveDescribeMetadata from '@salesforce/apex/MetadataBrowserLwcController.retrieveDescribeMetadata';
import retrieveListMetadata from '@salesforce/apex/MetadataBrowserLwcController.retrieveListMetadata';

export default class MetadataBrowser extends LightningElement {
    descMetaResult;
    gridColumns = [
        {
            type: 'text',
            fieldName: 'metadataType',
            label: 'Metadata Type',
        }
    ];
    @track gridData;
    @track expandedRows = [];
    
    get isMetadataListLoaded() {
        return !(!this.gridColumns) && !(!this.gridData);
    }
    
    @wire(retrieveDescribeMetadata, {})
    wiredDescribeMetadata({ error, data }) {
        if (data) {
            this.descMetaResult = JSON.parse(data);
            console.log(`this.descMetaResult: ${JSON.stringify(this.descMetaResult, null, 4)}`);
            this.populateGridData();
        } else if (error) {
            console.error(error);
        }
    }
    
    populateGridData() {
        const dataArray = [];
        console.log('Populating dataArray');
        this.descMetaResult.metadataObjects.forEach(metadataObj => {
            dataArray.push({
                metadataType: metadataObj.xmlName,
                hasCalledApi: false,
                inFolder: metadataObj.inFolder,
                _children: []
            });
        });
        dataArray.sort((itemA, itemB) => {
            return itemA.metadataType.localeCompare(itemB.metadataType)
        });
        this.gridData = dataArray;
    }
    
    // connectedCallback() {
    //     console.log('This one has children!');
    // }
    
    renderedCallback() {
        // console.log(`this.isMetadataListLoaded: ${this.isMetadataListLoaded}`);
    }
    
    handleToggle(event) {
        console.log(JSON.stringify(event.detail, null, 4));
        // event.detail:
        // {
        //     "name": "ApexClass",
        //     "isExpanded": true,
        //     "hasChildrenContent": false,
        //     "row": {
        //         "metadataType": "ApexClass",
        //         "hasCalledApi": false,
        //         "_children": []
        //     }
        // }
        if(!event.detail.row.hasCalledApi) {
            console.log(`I haven't called the Metadata API yet for this metadataType, I'm doin' it!!`);
            const mdType = event.detail.name;
            console.log(`mdType: ${mdType}`);
            retrieveListMetadata({ metadataTypeName: mdType })
            .then(result => {
                const listMetaResult = JSON.parse(result);
                console.log(`List Metadata Result: ${JSON.stringify(listMetaResult, null, 4)}`);
                // Find gridData node, set hasCalledApi to true, and populate it with children
                const idxCurrentNode = this.gridData.findIndex(node => node.name === mdType);
                const updatedNode = { ...this.gridData[idxCurrentNode] };
                updatedNode.hasCalledApi = true;
                console.log(`updatedNode: ${JSON.stringify(updatedNode, null, 4)}`);
                const childrenArray = listMetaResult.map(result => result.fullName);
                updatedNode._children = childrenArray;
                this.gridData[idxCurrentNode] = updatedNode;
            })
            .catch(error => {
                console.error(`List Metadata Error: ${JSON.stringify(error, null, 4)}`);
            });
        }
        if(!event.detail.isExpanded) {
            const idxCurrentNode = this.gridData.findIndex(node => node.name === event.detail.name);
            const updatedNode = { ...this.gridData[idxCurrentNode] };
            updatedNode.isExpanded = true;
            this.gridData[idxCurrentNode] = updatedNode;
        }
    }
    
    handleRowSelection(event) {
        console.log('Somebody selected something!');
    }
}