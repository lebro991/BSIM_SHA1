# BSIM_SHA1
工程的实现采用verilog ,仿真工具采用questsim，仿真采用UVM方法学进行了简单的仿真，设计仅供参考。




目前此工程中的数据填充部分的位宽仅支持128bit,如果需要支持更高的速率，可能需要增加数据填充部分的带宽。
工程的仿真也只做了填充部分的自动化check。


代码工程的基本架构图如下：

***************         ***************         ***************            ***************
*             *msg      *             *msg      *             *            *             *
*             *-------> * buff_data   *-------> *             *            *             *
*             *         *             *         *             *            *             *
*             *         ***************         *             *result_out  *             *result_out
*    padding  *                                 *sha1_cal_core*------->    *  pkt_order  **------->
*             *         ***************         *             *            *             *
*             *chanl_num*             *chanl_num*             *result_tag  *             *
*             *<------- * chanl_ctrl  *<------->*             *------->    *             *
*             *         *             *         *             *            *             *
***************         ***************         ***************            ***************
 

