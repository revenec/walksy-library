import { LightningElement, track } from 'lwc';

export default class WalksyGoogleMaps extends LightningElement {

    zoomLevel = "10";
    @track center;
    
    // Define the map markers (multiple locations)
    @track mapMarkers = [];

    mapOptions = {
        'disableDefaultUI': false, // when true disables Map|Satellite, +|- zoom buttons
        'draggable': true,
    }
    async connectedCallback() { 
        await this.getCurrentLocation();
    }
    
    // Handle map click event
    handleMapClick(event) {
        this.center = {
            location: {
                Latitude: event.detail.latLng.lat(),
                Longitude: event.detail.latLng.lng()
            }
        };
    }

    // Handle map marker click event
    handleMarkerClick(event) {
        const clickedMarker = this.mapMarkers.find(marker => marker.location.Latitude === event.detail.location.lat() && marker.location.Longitude === event.detail.location.lng());
        alert(`Clicked marker: ${clickedMarker.title}`);
    }

    // Handle map zoom change event
    handleMapZoomChange(event) {
        this.zoomLevel = event.detail.zoomLevel;
    }

    // Handle map drag event
    handleMapDragEnd(event) {
        this.center = {
            location: {
                Latitude: event.detail.center.lat(),
                Longitude: event.detail.center.lng()
            }
        };
    }

    getCurrentLocation() { 
        navigator.geolocation.watchPosition((position) => {
            this.center = {
                location: {
                    Latitude: position.coords.latitude, 
                    Longitude: position.coords.longitude
                }
            };
            const location = {location: this.center, title: 'Current Location', icon: 'standard:account'}
            this.mapMarkers.push(location);
       });
    }

    sliderChange(event) {
        this.zoomLevel = event.detail.value / 2;
    }

    handleMapClick(event) { 
        console.log('handleMapClick: ' + event.detail.value);
    }
}