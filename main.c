#include <stdio.h>
#include <stdlib.h>

//algorithms implemented in assembly
extern double power(double a,long b);
extern double exp(double x);
extern double exp2(double x);
extern double log(double x);
extern double fac(long n);
extern void merge_sort(long *a,long n);


//these are c versions of the assembly functions in asm.s
void sort(long *a,long n){
    if(n<=1) return;
    sort(a,n/2);
    sort(a+n/2,n-n/2);
    long *c=malloc(n*sizeof(long));
    int j=0,k=n/2;
    for(int i=0;i<n;i++){
        if(j<n/2 && (a[j]<a[k] || k==n)){
            c[i]=a[j];
            j++;
        }else{
            c[i]=a[k];
            k++;
        }
    }
    for(int i=0;i<n;i++) a[i]=c[i];
    free(c);
}

double expc(double x){
    double s=1;
    double a=1;
    for(double n=1;n<400;n++){
        a/=n;
        a*=x;
        s+=a;
    }
    return s;
}

double logc(double x){
    if(x<=0) return 0./0.;
    double sgn=1;
    if(x>1){
        x=1/x;
        sgn=-1;
    };
    x-=1;
    double s=0;
    double p=x;
    for(double n=1;n<400;n++){
        double t=sgn*p/n;
        s+=t;
        p*=x;
        sgn*=-1;
    }
    return s;
}


int main(){
    long a[]={9,8,7,6,5,4,3,2,1,0};
    long n=10;
    
    printf("assembly merge sort:\n");
    printf("\tbefore sorting [");
    for(int i=0;i<n;i++){
        printf("%ld,",a[i]);
    }
    printf("]\n");
    merge_sort(a,n );
    printf("\tafter sorting  [");
    for(int i=0;i<n;i++){
        printf("%ld,",a[i]);
    }
    printf("]\n");
    
    
    printf("assembly exponential:\n");
    for(int i=0;i<10;i++){
        printf("\texp(%d)=%.15f\n",i,exp(i));
    }
    printf("assembly logarithm:\n");
    for(int i=0;i<10;i+=1){
        printf("\tlog(%d)=%.15f\n",i,log(i));
    }
}


