function result = BLRH_solve_Honda(testlabels,traininglabels,TrainingSets,TestSets,alpha,beta,nbits,r,frameNum,anchor_num)

seed = 0;
rng('default');
rng(seed);

TestLab = testlabels;
TrainLab = traininglabels;
TestData = TestSets;
options.KernelType = 'Gaussian';
dl=10;
trainSetNum=20;
trainN = length(unique(TrainLab));
ytrain= [];
Dic = [];



for i = 1:trainN
    temp1 = double(TrainingSets(:,find(TrainLab==i)));
    if size(temp1,2)>=frameNum
        temp1 = temp1(:,1:frameNum);
    end
    temp1 = NormalizeFea(temp1, 0);
    ygallery(i) = i;
    ytrain=[ytrain,i*ones(1,size(temp1,2))];
    Dic=[Dic,temp1];
end



Y_label=zeros(trainN,trainSetNum);
for i_label = 1:trainSetNum
    Y_label(ytrain(i_label*frameNum),i_label)=1;
end
I_label=zeros(trainN,trainSetNum*frameNum)';
for i_label = 1:frameNum*trainSetNum
    I_label(i_label,ytrain(i_label))=1;
end







if anchor_num==0
    K=Dic';
else
    options.t = mean(mean(EuDist2(Dic)));
    anchor_choose=[];
    ran_index=randperm(frameNum,anchor_num);
    anchor_sort=sort(ran_index);
    for inter = 1:trainSetNum
        anchor_choose = [anchor_choose,anchor_sort+(inter-1)*frameNum];
    end
    K = buildKernel(Dic',Dic(:,anchor_choose)',options);
end


testNum = length(TestLab);
Xtest = cell(testNum,1);
j = 0;
ytest = zeros(testNum,1);
for i = 1: testNum
    j = j + 1;
    temp1 = double(TestData{1,i});
    if size(temp1,2)>=frameNum
        temp1 = temp1(:,1:frameNum);
    else
        temp1 = temp1(:,1:size(temp1,2));
    end
    temp1 = NormalizeFea(temp1, 0);
    Xtest{j}=temp1;
    ytest(j)=TestLab(i);
end


len = nbits;
[n,~] = size(I_label);
XTX =K'*K;

for cross_valid=1:1
    
    %------------------------------initialize--------------------------------------------   
    [~,dv] = size(K);
    M = zeros(dv,dv);  
    temp_B = randsrc(len,n/(frameNum),[-1,1]);
    B=kron(temp_B,ones(1,frameNum))';
    %--------- P-step
    St = XTX+alpha*M;
    Sb = K'*B*B'*K;
    [P, ~, ~]=eig1((St\Sb), r, 1);    
    %--------- Q-step
    Q = (P'*St*P)\(P'*K'*B);    
    %--------- M-step
    PQ = P*Q;
    v  = sqrt(sum(PQ.*PQ,2)+eps);
    M  = diag(1./(2*v));   
    %-----inital R
    [R1,~,SR] = svd(B'*I_label,'econ');
    R = R1*SR';
 
    
    %------------------------------training--------------------------------------------
    
    for lenoops=1:dl
        LapA=B;
        %--------- B-step
        B_C = (K*P*Q+beta*I_label*R')';
        B=hash_const(B_C,len,n)';       
        %--------- P-step
        St = XTX+alpha*M;
        Sb = K'*B*B'*K;
        [P, ~, ~]=eig1((St\Sb), r, 1);        
        %--------- Q-step
        Q = (P'*St*P)\(P'*K'*B);      
        %--------- M-step
        PQ = P*Q;
        v  = sqrt(sum(PQ.*PQ,2)+eps);
        M  = diag(1./(2*v));
        %--------- R-step
        [R1,~,SR] = svd(B'*I_label,'econ');
        R = R1*SR';
   
%         LapAold=B;
%         obj(lenoops) = norm(LapA-LapAold,'fro')^2/norm(LapAold,'fro')^2;
        
    end
    %          plot(obj);
    
    % TQ=PQ;
    % TQ = NormalizeFea(TQ,0);
    % TQ(find(abs(TQ)<0.14))=0;
    % imagesc(TQ);
    % colormap('lines');%prism
    % %colormap(parula(14))
    % % colormap('lines');
    % axis off;colorbar
    % set(gcf, 'position', [0 0 300 300]);
       
    B_train = B';
  
    s = 0;   
    for it=1:testNum
        s = s + 1;
        Y=Xtest{it};
        
        
        if anchor_num==0
            K_Y=Y';
        else
            K_Y = buildKernel(Y',Dic(:,anchor_choose)',options);
        end
        
        B_test = sgn(K_Y*P*Q)';
        %--------------hamming distance--------------------
        B_train_c = logical(B_train == 1);
        B_test_c = logical(B_test == 1);
       
        B = compactbit(B_train_c');
        tB = compactbit(B_test_c');
       
        hammTrainTest = hammingDist(tB, B)';
        
        %------------vote--------------------
        label = zeros(1,trainN);
        index_temp=[];
        label_each=zeros(1,trainN);
        for i = 1 : size(Y,2)   
            dis_col =  hammTrainTest(:,i);
            col_min_value=find(dis_col==min(dis_col));
            ind_ham=ceil(col_min_value/(frameNum));
            
            for index_ham=1:size(ind_ham)
                flag=ind_ham(index_ham);
                label(flag)=label(flag)+1;
            end
            [~,index_vote1] = max(label);
            label_each(index_vote1) = label_each(index_vote1)+1;
        end
        [~,index_vote] = max(label_each);
        
        
        
        
        
        %                 if ytest(it) ~= index_vote
        %                     fprintf('[%2d]True:%2d, Pred:%d\tX\n',s,ytest(it), index_vote);
        %                 else
        %                     fprintf('[%2d]True:%2d, Pred:%d\n',s,ytest(it), index_vote);
        %                 end
        pred(s) = index_vote;
        groudtrue(s) = ytest(it);
    end
    Rate_cross(cross_valid)=length(find(pred==groudtrue))./length(groudtrue);
    
end
acuu_mean=mean(Rate_cross);
acc_std=std(Rate_cross);
result=[acuu_mean acc_std]
end


