### **1. 简介**

本文档旨在说明如何将Faceunity Nama SDK的 HarmonyOS Demo运行起来，体验Faceunity Nama SDK的功能。FULiveDemo 是集成了 Faceunity 面部跟踪、美颜、Animoji、道具贴纸、AR面具、表情识别、音乐滤镜、人像分割、手势识别、哈哈镜以及Avatar 捏脸功能的Demo。Demo将根据客户证书权限来控制用户可以使用哪些产品。

### **2. 运行Demo**

#### **2.1 开发环境**

- IDE版本：5.0.3.800
- API版本：12
- 设备版本：NEXT.0.0.65

#### **2.2 准备工作**

- [下载FULiveDemo](https://github.com/Faceunity/FULiveDemo-harmonyOS)
- 根目录 build-profile.json5 中的 signingConfigs 密钥数据，需要登陆华为账号自动生成。
- 替换自己的证书，/entry/src/main/ets/auth/FUNMAuth.ets 中 g_auth_package 需要替换为自己的证书信息，获取证书 见 **2.3.1。**

#### **2.3 相关配置**

##### **2.3.1 导入证书**

您需要拥有我司颁发的证书才能使用我们的SDK的功能，获取证书方法：

1、拨打电话 **0571-89774660**

2、发送邮件至 **[marketing@faceunity.com](mailto:marketing@faceunity.com)** 进行咨询。

HarmonyOS 端发放的证书为包含在authpack 开头的.ets 文件中的g_auth_package数组，如果您已经获取到鉴权证书，将证书中的g_auth_package数组复制到Demo 中的 FUNMAuth.ets 中即可。根据应用需求，鉴权数据也可以在运行时提供(如网络下载)，不过要注意证书泄露风险，防止证书被滥用。

#### **2.4 编译运行**



