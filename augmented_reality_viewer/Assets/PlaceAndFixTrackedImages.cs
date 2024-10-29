using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class PlaceAndFixTrackedImages : MonoBehaviour
{
    private ARTrackedImageManager aRTrackedImageManager;
    public GameObject[] aRModelsToAnchor;

    private Dictionary<string, GameObject> _aRModels = new Dictionary<string, GameObject>();
    private Dictionary<string, bool> _modelState = new Dictionary<string, bool>();

    void Awake()
    {
        aRTrackedImageManager = GetComponent<ARTrackedImageManager>();
    }

    private void OnEnable()
    {
        aRTrackedImageManager.trackedImagesChanged += ImageFound;
    }

    private void OnDisable()
    {
        aRTrackedImageManager.trackedImagesChanged -= ImageFound;
    }

    // Start is called before the first frame update
    void Start()
    {
        foreach (var aRModel in aRModelsToAnchor)
        {
            GameObject newARModel = Instantiate(aRModel, Vector3.zero, Quaternion.identity);
            newARModel.name = aRModel.name;
            _aRModels.Add(newARModel.name, newARModel);
            newARModel.SetActive(false);
            _modelState.Add(newARModel.name, false);
        }
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void ImageFound(ARTrackedImagesChangedEventArgs obj)
    {
        foreach (var trackedImage in obj.updated)
        {
            SpawnARModel(trackedImage);
        }
        //foreach (var trackedImage in obj.updated)
        //{
        //    if (trackedImage.trackingState == TrackingState.Tracking)
        //    {
        //        SpawnARModel(trackedImage);
        //    }
        //    //else if (trackedImage.trackingState == TrackingState.Limited)
        //    //{
        //    //    HideARModel(trackedImage);
        //    //}
        //}
    }

    private void SpawnARModel(ARTrackedImage trackedImage)
    {
        bool isActive = _modelState[trackedImage.referenceImage.name];
        if (!isActive)
        {
            GameObject aRModel = _aRModels[trackedImage.referenceImage.name];
            aRModel.transform.position = trackedImage.transform.position;
            aRModel.SetActive(true);
            _modelState[trackedImage.referenceImage.name] = true;
        }
        //else
        //{
        //    GameObject aRModel = _aRModels[trackedImage.referenceImage.name];
        //    aRModel.transform.position = trackedImage.transform.position;
        //}
    }

    private void HideARModel(ARTrackedImage trackedImage)
    {
        bool isActive = _modelState[trackedImage.referenceImage.name];
        if (isActive)
        {
            GameObject aRModel = _aRModels[trackedImage.referenceImage.name];
            aRModel.SetActive(false);
            _modelState[trackedImage.referenceImage.name] = false;
        }
    }

}
