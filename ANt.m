%cities coodinates
x = [3 2 12 7  9  3 16 11 9 2];
y = [1 4 2 4.5 9 1.5 11 8 10 7];

%number of cities
N = size(x,2);
%control paremeter
alfa = 1;
beta = 5;
% distances between cities
d = zeros(size(x,2), size(x,2));

%pheromone evaporation
p = 0.5;
%intitial pheromone value
Tau0 = 0.1;

% amount of pheromone
Tau = zeros(size(x,2), size(x,2));

%calculating distances
for i=1:N
    for j=1:N
        if i==j
            d(i,j)=inf;
        else
            d(i,j)= sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2);
        end
    end
end

%set intial amount of pheromone
for i=1:N
    for j=1:N
        if i==j
            Tau(i,j)=0;
        else
            Tau(i,j)= Tau0;
        end
    end
end

%number of interations
nr_iteration = 100;
%number of ants
nr_ants = 10;
%choosing home cities for each ant
home_city = randi([1 10],1,nr_ants);

%interation counter
t = 0;

%main loop
while true
    t = t + 1;
            
    distance_of_tour = zeros(1, nr_ants);
    all_tour_data = zeros(nr_ants,N);
        
    %Ant System loop
    for k=1:nr_ants
        Set_of_cities = [1 2 3 4 5 6 7 8 9 10];

        used_ways = zeros(size(x,2), size(x,2));
        
        Set_of_cities(home_city(k))=[];
        Tour = home_city(k);
        
        % Ant memory
        A =  zeros(size(x,2), size(x,2));
        sumA = zeros(size(x));
        for i=1:N
            for j=1:N
                if i==j
                    A(i,j)=0;
                else
                    A(i,j)= Tau(i,j)^alfa * d(i,j)^(-beta);
                end
                sumA(i) = sumA(i)+ A(i,j);
            end
        end
        
        for i=1:N
            for j=1:N
                    A(i,j)= A(i,j)/sumA(i);
            end
        end

        
        current_city = home_city(k);
        count_iter = 1;
        
        % performing tour loop
        while true
            
            % Probability
            Probability = zeros(size(Set_of_cities)); 
            sumP = 0;
            for j=1:size(Set_of_cities,2)
                Probability(j) = A(current_city,Set_of_cities(j));
                sumP = sumP + Probability(j);
            end
            
            for j=1:size(Set_of_cities,2)
                Probability(j) =  Probability(j)/sumP;
            end
            
            % choosing way
            random = rand();
            prob = 0;
            for i=1:size(Set_of_cities,2)
                prob = prob + Probability(i);
                if random < prob
                    id_city_to_go = Set_of_cities(i);
                    break
                end
            end
            
            % update tour distance 
            distance_of_tour(k) = distance_of_tour(k) + d(id_city_to_go,current_city);
            used_ways(id_city_to_go,current_city) = 1;
            
            for counter=1:size(Set_of_cities,2)
                if Set_of_cities(counter) == id_city_to_go
                    current_city = Set_of_cities(counter);
                    Set_of_cities(counter)=[];
                    break
                end
            end    
            
            count_iter = count_iter + 1;
            % save tour data
            Tour(count_iter) = current_city;
            
            if size(Set_of_cities,2) == 0
                break
            end
        end
        
        distance_of_tour(k) = distance_of_tour(k) + d(home_city(k),current_city);
        used_ways(home_city(k),current_city) = 1;
        all_ant_used_ways(:,:,k) = used_ways;
        
        all_tour_data(k,:) = Tour;
    end
    distance_of_tour = transpose(distance_of_tour);
    
    
    % update pheromones 
    for i=1:N
        for j=1:N
            delta_tau = 0;
            for k=1:nr_ants                    
                if all_ant_used_ways(i,j,k) == 1
                    delta_tau = delta_tau + 1/distance_of_tour(k);
                end
                if all_ant_used_ways(j,i,k) == 1
                    delta_tau = delta_tau + 1/distance_of_tour(k);
                end
            end
            Tau(i,j) = (1 - p) * Tau(i,j) + delta_tau;
        end    
    end
    
    if t == nr_iteration
        break
    end
end 

%all_tour_data = [distance_of_tour all_tour_data];
%all_tour_data = sortrows(all_tour_data,11);

[best_dist best_tour] = min(distance_of_tour);
%minimum = min(distance_of_tour);
%best_ant = find(distance_of_tour==minimum);
display('best tour =');
display(all_tour_data(1,:));
display(best_dist);


[r,c,v] = find(hankel(2:N)); %create unique combinations of indices
index = [v c].'; %reshape the indices
plot(x(index),y(index),'g:'); %plot the lines
hold on
plot(x,y,'r*'); % Plot the points
hold on
plot(x([all_tour_data(best_tour,:) all_tour_data(best_tour,1)]), y([all_tour_data(best_tour,:) all_tour_data(best_tour,1)]), 'k');
hold on