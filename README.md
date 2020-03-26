### ImageRendered
### 高效图片渲染Demo
![图片](https://eoimages.gsfc.nasa.gov/images/imagerecords/78000/78314/VIIRS_3Feb2012_front.jpg)
###### 想要完整渲染这张宽高为 12,000 px 的图片，需要高达 20 MB 的空间。但那只是它压缩后的尺寸,要展示它，UIImageView 首先需要把 JPEG 数据解码成位图（bitmap），如果要在一个 UIImageView 上按原样设置这张全尺寸图片，你的应用内存占用将会激增到几百兆，对用户明显没有什么好处（毕竟，屏幕能显示的像素有限）。但只要在设置 UIImageView 的 image 属性之前，将图像渲染的尺寸调整成 UIImageView 的大小，你用到的内存就会少一个数量级。
[参考文献](https://nshipster.com/image-resizing/)
