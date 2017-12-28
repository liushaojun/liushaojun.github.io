title: nio文件读写操作
date: 2016-04-12 14:25:06
categories: java
tags: [ java , NIO]
---

>nio 是New IO 的简称，在jdk1.4 里提供的新api 。Sun 官方标榜的特性如下： 为所有的原始类型提供(Buffer)缓存支持。字符集编码解码解决方案。 Channel ：一个新的原始I/O 抽象。 支持锁和内存映射文件的文件访问接口。 提供多路(non-bloking) 非阻塞式的高伸缩性网络I/O 。                 -- 摘抄[百度百科](http://baike.baidu.com/link?url=0RUl92U3LPlc5CgZbBAqVtjxbkH-esxau7LX6iEWLtUBESNf7xuDuTbRJ8A3Ruf0LlD_i25c1Bt3N2r_RnMH9zDzqaZ3bgMmMLitEQ8qYfhk_2ZRqmvJW5-gtskoZDi7w9BO7mdHxXybb3KekHpul_)

<!-- more -->

## 代码

``` java
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.util.Date;

public class NIO {

  public static void main(String args[]) throws Exception {

    int bufSize = 1000000;//一次读取的字节长度
    File fin = new File("D:\\test\\readFile.txt");//读取的文件
    File fout = new File("D:\\test\\writeFile.txt");//写出的文件
    Date startDate = new Date();
    FileChannel fcin = new RandomAccessFile(fin, "r").getChannel();
    ByteBuffer rBuffer = ByteBuffer.allocate(bufSize);

    FileChannel fcout = new RandomAccessFile(fout, "rws").getChannel();
    ByteBuffer wBuffer = ByteBuffer.allocateDirect(bufSize);

    readFileByLine(bufSize, fcin, rBuffer, fcout, wBuffer);
    Date endDate = new Date();
    
    System.out.print(startDate+"|"+endDate);//测试执行时间
  }

  public static void readFileByLine(int bufSize, FileChannel fcin,
      ByteBuffer rBuffer, FileChannel fcout, ByteBuffer wBuffer) {
    String enterStr = "\n";
    try {
      byte[] bs = new byte[bufSize];
      //temp：由于是按固定字节读取，在一次读取中，第一行和最后一行经常是不完整的行，因此定义此变量来存储上次的最后一行和这次的第一行的内容，
      //并将之连接成完成的一行，否则会出现汉字被拆分成2个字节，并被提前转换成字符串而乱码的问题，数组大小应大于文件中最长一行的字节数
      byte[] temp = new byte[500];
      while (fcin.read(rBuffer) != -1) {
        int rSize = rBuffer.position();
        rBuffer.rewind();
        rBuffer.get(bs);
        rBuffer.clear();
        
        //windows下ascii值13、10是换行和回车，unix下ascii值10是换行
        //从开头顺序遍历，找到第一个换行符
        int startNum=0;
        int length=0;
        for(int i=0;i<rSize;i++){
          if(bs[i]==10){//找到换行字符
            startNum=i;
            for(int k=0;k<500;k++){
              if(temp[k]==0){//temp已经存储了上一次读取的最后一行，因此遍历找到空字符位置，继续存储此次的第一行内容，连接成完成一行
                length=i+k;
                for(int j=0;j<=i;j++){
                  temp[k+j]=bs[j];
                }
                break;
              }
            }
            break;
          }
        }
        //将拼凑出来的完整的一行转换成字符串
        String tempString1 = new String(temp, 0, length+1, "GBK");
        //清空temp数组
        for(int i=0;i<temp.length;i++){
          temp[i]=0;
        }
        //从末尾倒序遍历，找到第一个换行符
        int endNum=0;
        int k = 0;
        for(int i=rSize-1;i>=0;i--){
          if(bs[i]==10){
            endNum=i;//记录最后一个换行符的位置
            for(int j=i+1;j<rSize;j++){
              temp[k++]=bs[j];//将此次读取的最后一行的不完整字节存储在temp数组，用来跟下一次读取的第一行拼接成完成一行
              bs[j]=0;
            }
            break;
          }
        }
        //去掉第一行和最后一行不完整的，将中间所有完整的行转换成字符串
        String tempString2 = new String(bs, startNum+1, endNum-startNum, "GBK");
        
        //拼接两个字符串
        String tempString = tempString1 + tempString2;
//        System.out.print(tempString);
        
        int fromIndex = 0;
        int endIndex = 0;
        while ((endIndex = tempString.indexOf(enterStr, fromIndex)) != -1) {
          String line = tempString.substring(fromIndex, endIndex)+enterStr;//按行截取字符串
          System.out.print(line);
          //写入文件
          writeFileByLine(fcout, wBuffer, line);

          fromIndex = endIndex + 1;
        }
      }
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  /**
   * 写到文件上
   * @param fcout
   * @param wBuffer
   * @param line
   */
  @SuppressWarnings("static-access")
  public static void writeFileByLine(FileChannel fcout, ByteBuffer wBuffer, String line) {
    try {
      fcout.write(wBuffer.wrap(line.getBytes("UTF-8")), fcout.size());
    } catch (IOException e) {
      e.printStackTrace();
    }
  }
}
```
