# Flutter Image Classification/ Object Detection App
![Screen shots](assets/tflite.png)
An image classification/object detectection app using Google Teachable Machine to upload an image dataset for 3 classes: Cat, Dog and Unknown (Background Images). Trained and exported in TensorFlowLite file from which the home page is designed to make the model usable in a mobile app. User can import images both from camera and gallery.

## Documentation
- Train model at [Google Teachable Machine](https://teachablemachine.withgoogle.com/)
- Dataset is taken from [Kaggle-Cats & Dogs](https://www.kaggle.com/datasets/samuelcortinhas/cats-and-dogs-image-classification) and [Kaggle-Unknown](https://www.kaggle.com/datasets/lprdosmil/unsplash-random-images-collection)
- 279 images of Cats, 278 images of Dog and 802 images of Unknown (background images) were used to train the model.
- Confidence level is set at home_page.dart, if confidence level is low of < 0.9, then cat or dog isn't detected.
- Matrix is (1,3) since 3 classes were used, if more classes are used then need to make a change in the code line 110 in image_classifier.dart, to increase/decrease the class 'x' used

```bash
final output = List.filled(1 * x, 0.0).reshape([1, x]);
```
## Output
- Achieved accuracy of around 76%