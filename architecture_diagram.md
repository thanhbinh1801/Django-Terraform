# Kiến trúc Hạ tầng Hệ thống trên AWS (Infrastructure Architecture)

Dựa trên toàn bộ mã nguồn Terraform của dự án, đây là bản thiết kế hệ thống chuyên nghiệp mô tả đường đi của mạng lưới, máy chủ ECS và cơ sở dữ liệu RDS của bạn.

## Sơ đồ Tổng quan Mạng (Network & Components)

```mermaid
graph TD
    %% Định nghĩa các lớp người dùng bên ngoài
    Client((Người dùng<br/>Internet))

    %% Khu vực bao ngoài cùng của AWS
    subgraph AWS_Cloud ["☁️ AWS Cloud (Region: ap-southeast-2)"]
        style AWS_Cloud fill:#ffffff,stroke:#ff9900,stroke-width:2px,color:#000
        
        IGW["🌐 Internet Gateway (IGW)"]
        ECR["📦 Amazon ECR<br/>(Lưu Docker Image)"]
        S3["🪣 Amazon S3<br/>(Lưu file tĩnh/Asset)"]
        
        %% Mạng VPC chính
        subgraph VPC ["🔒 Tòa nhà mạng VPC (10.0.0.0/16)"]
            style VPC fill:#f8f9fa,stroke:#17a2b8,stroke-width:2px,color:#000

            %% Subnet Công cộng (Public)
            subgraph Public_Zone ["🌍 Khu vực Public (2 Subnets)"]
                style Public_Zone fill:#d4edda,stroke:#28a745,stroke-width:2px,stroke-dasharray: 5 5,color:#000
                
                ECS_SG["🛡️ Security Group: cho phép Port 8000 từ mọi nơi"]
                
                subgraph ECS_Cluster ["⚙️ Cụm Tín toán ECS Cluster"]
                    style ECS_Cluster fill:#cce5ff,stroke:#007bff,stroke-width:1px,color:#000
                    ECS_Task["🐳 ECS Fargate Task<br/>(App Django Chạy ở Port 8000)"]
                end
                
                ECS_SG -. bọc bảo vệ .-> ECS_Task
            end

            %% Subnet Riêng Tư (Private)
            subgraph Private_Zone ["🛑 Khu vực Private Tuyệt Mật (2 Subnets)"]
                style Private_Zone fill:#f8d7da,stroke:#dc3545,stroke-width:2px,stroke-dasharray: 5 5,color:#000
                
                RDS_SG["🛡️ Security Group: CHỈ cho phép Port 5432 từ ECS_SG"]
                
                RDS[("🐘 RDS PostgreSQL Database\n(dbadmin / mydb)")]
                
                RDS_SG -. bọc bảo vệ .-> RDS
            end
        end
    end

    %% Flow mũi tên tương tác
    Client -- "Truy cập TCP:8000" --> IGW
    IGW -- "Đẩy Traffic vào VPC" --> ECS_Task
    
    ECS_Task -- "Truy vấn Dữ liệu (Port 5432)" --> RDS
    ECS_Task -- "Tải/Up file tĩnh" --> S3
    ECS_Task -- "Kéo tải Docker image\nkhi khởi động" --> ECR
```

## Giải thích Luồng Hoạt động (Workflows)

1. **Truy cập của Người dùng (Client Flow):**
   - Khách hàng trên mạng gõ địa chỉ IP Public của hệ thống kèm cổng `8000` (VD: `http://1.2.3.4:8000`).
   - Yêu cầu vượt qua cổng bảo vệ **Internet Gateway (IGW)** của AWS, đi qua lớp lọc **Security Group của ECS** và chạy thẳng vào nhân xử lý Code của Django App đang được "thầu" bởi máy chủ ECS Fargate.

2. **Cách App tương tác Dữ liệu (Backend Flow):**
   - Khi Django cần lôi dữ liệu ra (lấy User, Posts...), nó sẽ lấy thông số môi trường mà Terraform đã bơm sẵn, gọi xuyên qua tường lửa vào khu vực tuyệt mật (Private Subnet) để hỏi chuyện ổ cứng Database **PostgreSQL** ở cổng `5432`.
   - Vì khu vực Private này không nối với cổng IGW ra ngoài internet, Hacker không thể nào ping trực tiếp vào cục Database `mydb` của bạn được, chỉ có thằng App Django đứng kề bên nó mới được phép soi chiếu. Đây là độ bảo mật rất cao.

3. **Cơ chế Triển khai (CI/CD Flow):**
   - Khi bạn (Dev) đẩy tính năng mới lên GitHub -> GitHub Actions sẽ đóng gói nguyên khối Django App này và vứt nó lên kho lưu trữ **Amazon ECR** trên mây.
   - Thằng kho ECR lập tức gõ cửa báo cho cụm **ECS Fargate**, cụm ECS sẽ tắt máy cũ đi, qua kho ECR nhặt nguyên mẫu hộp image mới về bật lên chạy lại phục vụ phớt lờ máy cũ tự hủy. Quá trình triển khai không ngừng nghỉ.
