# coreml

## Links

* [Apple CoreML](https://developer.apple.com/machine-learning)
* [Caffe Model Zoo - public available models](https://github.com/BVLC/caffe/wiki/Model-Zoo)

##  Convert Caffe to CoreML models
```
$ virtualenv -p /usr/bin/python2.7 env
$ source env/bin/activate
$ pip install tensorflow
$ pip install keras==1.2.2
$ pip install coremltools
```

```python
import coremltools

coreml_model = coremltools.converters.caffe.convert(('MODEL.caffemodel', 'DEPLOY.prototxt'),
image_input_names='data',
is_bgr=True,
class_labels='NAMES.txt')

coreml_model.author = 'some author'
coreml_model.license = 'Creative Commons Attribution License'
coreml_model.short_description = 'some model description'

coreml_model.input_description['data'] = 'Image of something in the format 224x224'

coreml_model.output_description['classLabel'] = 'Name of the result'

coreml_model.save('names.mlmodel')
```

##  Convert MathLab names file to txt

```python
import scipy.io as sio
names = sio.loadmat('downloads/SOME_FILE.mat')
for item in names['make_model_names']:
print item[1][0]
```
